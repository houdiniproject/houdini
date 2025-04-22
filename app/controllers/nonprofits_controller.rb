# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NonprofitsController < ApplicationController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization
  include Controllers::XFrame

  helper_method :current_nonprofit_user?
  before_action :authenticate_nonprofit_user!, only: %i[dashboard dashboard_metrics dashboard_todos payment_history profile_todos recurring_donation_stats update verify_identity]
  before_action :authenticate_super_admin!, if: proc { |c| (c.action_name == "destroy") || (c.action_name == "show" && !current_nonprofit.published) }

  # we have to allow nonprofits/:id/donation and nonprofits/:id/btn to be framed
  after_action :allow_framing, only: %i[donate btn]

  # get /nonprofits/:id
  # get /:state_code/:city/:name
  def show
    @nonprofit = current_nonprofit
    @url = Format::Url.concat(root_url, @nonprofit.url)
    @supporters = @nonprofit.supporters.not_deleted

    events = @nonprofit.events.not_deleted.order("start_datetime desc")
    campaigns = @nonprofit.campaigns.not_deleted.not_a_child.order("created_at desc")

    @events = events.upcoming
    @any_past_events = events.past.any?
    @active_campaigns = campaigns.active
    @any_past_campaigns = campaigns.past.any?

    @nonprofit_background_image = @nonprofit.background_image.attached? ?
      url_for(@nonprofit.background_image_by_size(:normal)) :
      url_for(Houdini.defaults.image.nonprofit)

    respond_to do |format|
      format.html
      format.json { @nonprofit }
    end
  end

  def recurring_donation_stats
    render json: QueryRecurringDonations.overall_stats(params[:nonprofit_id])
  end

  def profile_todos
    render json: FetchTodoStatus.for_profile(current_nonprofit)
  end

  def dashboard_todos
    render json: FetchTodoStatus.for_dashboard(current_nonprofit)
  end

  def update
    flash[:notice] = "Update successful!"
    current_nonprofit.update! nonprofit_params.except(:verification_status)
    render :show
  end

  def destroy
    current_nonprofit.destroy
    flash[:notice] = "Nonprofit removed"
    render json: {}
  end

  # get /nonprofits/:id/donate
  def donate
    @nonprofit = current_nonprofit
    @referer = params[:origin] || request.env["HTTP_REFERER"]
    @campaign = current_nonprofit.campaigns.find_by_id(params[:campaign_id]) if params[:campaign_id]
    @countries_translations = countries_list(I18n.locale)
    respond_to { |format| format.html { render layout: "layouts/embed" } }
  end

  def btn
    @nonprofit = current_nonprofit
    respond_to { |format| format.html { render layout: "layouts/embed" } }
  end

  # get /nonprofits/:id/supporter_form
  def supporter_form
    @nonprofit = current_nonprofit
    respond_to { |format| format.html { render layout: "layouts/embed" } }
  end

  # post /nonprofits/:id/supporter_with_tag
  def custom_supporter
    @nonprofit = current_nonprofit
    render json: InsertSupporter.with_tags_and_fields(@nonprofit.id, params[:supporter])
  end

  def dashboard
    @nonprofit = current_nonprofit
    respond_to { |format| format.html }
  end

  def dashboard_metrics
    render json: Hamster::Hash[data: NonprofitMetrics.all_metrics(current_nonprofit.id)]
  end

  def payment_history
    render json: NonprofitMetrics.payment_history(params)
  end

  # put /nonprofits/:id/verify_identity
  def verify_identity
    if params[:legal_entity][:address]
      tos = {
        ip: current_user.current_sign_in_ip,
        date: Time.current.to_i,
        user_agent: request.user_agent
      }
    end
    render_json { UpdateNonprofit.verify_identity(params[:nonprofit_id], params[:legal_entity], tos) }
  end

  def search
    render json: QueryNonprofits.by_search_string(params[:npo_name])
  end

  private

  def countries_list(locale)
    all_countries = ISO3166::Country.translations(locale)

    if Houdini.intl.all_countries
      countries = all_countries.select { |code, _name| Houdini.intl.all_countries.include? code }
      countries.map { |code, name| [code.upcase, name] }.sort_by { |a| a[1] }

    else
      all_countries.map { |code, name| [code.upcase, name] }.sort_by { |a| a[1] }
    end
  end

  def nonprofit_params
    params.require(:nonprofit).permit(
      :name,
      :stripe_account_id,
      :summary,
      :tagline,
      :email,
      :phone,
      :main_image,
      :background_image,
      :remove_background_image,
      :logo,
      :zip_code,
      :website,
      :categories,
      :achievements,
      :full_description,
      :state_code,
      :statement,
      :city,
      :slug,
      :city_slug,
      :state_code_slug,
      :ein,
      :published,
      :vetted,
      :verification_status,
      :timezone,
      :address,
      :thank_you_note,
      :referrer,
      :no_anon,
      :roles_attributes,
      :brand_font,
      :brand_color,
      :hide_activity_feed,
      :tracking_script,
      :facebook,
      :twitter,
      :youtube,
      :instagram,
      :blog,
      :card_failure_message_top,
      :card_failure_message_bottom,
      :autocomplete_supporter_address
    )
  end
end
