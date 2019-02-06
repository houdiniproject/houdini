# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
 class NonprofitsController < ApplicationController
	include Controllers::NonprofitHelper

	helper_method :current_nonprofit_user?
	before_filter :authenticate_nonprofit_user!, only: [:dashboard, :dashboard_metrics, :dashboard_todos, :payment_history, :profile_todos, :recurring_donation_stats, :update, :verify_identity]
	before_filter :authenticate_super_admin!, only: [:destroy]

	# get /nonprofits/:id
	# get /:state_code/:city/:name
	def show
    if !current_nonprofit.published && !current_role?(:super_admin)
       block_with_sign_in
      return
    end
		@nonprofit = current_nonprofit
		@url = Format::Url.concat(root_url, @nonprofit.url)
		@supporters = @nonprofit.supporters.not_deleted
		@profiles = @nonprofit.profiles.order('total_raised DESC').limit(5).includes(:user).uniq

    events = @nonprofit.events.not_deleted.order('start_datetime desc')
    campaigns = @nonprofit.campaigns.not_deleted.not_a_child.order('created_at desc')

		@events = events.upcoming
		@any_past_events = events.past.any?
		@active_campaigns = campaigns.active
		@any_past_campaigns = campaigns.past.any?

		@nonprofit_background_image =  FetchBackgroundImage.with_model(@nonprofit)

		respond_to do |format|
			format.html
			format.json {render json: @nonprofit}
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

	def create
    current_user ||= User.find(params[:user_id])
		json_saved Nonprofit.register(current_user, params[:nonprofit])
	end

	def update
		flash[:notice] = 'Update successful!'
    current_nonprofit.update_attributes params[:nonprofit].except(:verification_status)
		json_saved current_nonprofit
	end

	def destroy
		current_nonprofit.destroy
		flash[:notice] = 'Nonprofit removed'
		render json: {}
	end

  # get /nonprofits/:id/donate
  def donate
    @nonprofit = current_nonprofit
    @referer = params[:origin] || request.env['HTTP_REFERER']
    @campaign = current_nonprofit.campaigns.find_by_id(params[:campaign_id]) if params[:campaign_id]
    @countries_translations = countries_list(I18n.locale)
    respond_to { |format| format.html{render layout: 'layouts/embed'} }
  end

	def btn
		@nonprofit = current_nonprofit
		respond_to { |format| format.html{render layout: 'layouts/embed'} }
	end

  # get /nonprofits/:id/supporter_form
  def supporter_form
		@nonprofit = current_nonprofit
		respond_to { |format| format.html{render layout: 'layouts/embed'} }
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
    render_json{ UpdateNonprofit.verify_identity(params[:nonprofit_id], params[:legal_entity], tos) }
	end

  def search
    render json: QueryNonprofits.by_search_string(params[:npo_name])
  end

  def onboard
    render_json do
      result = OnboardAccounts.create_org(params)
      sign_in result[:user]
      result
    end
  end

  private

  def countries_list(locale)
    all_countries = ISO3166::Country.translations(locale)

    if Settings.intntl.all_countries
      countries = all_countries.select{ |code, name| Settings.intntl.all_countries.include? code }
      countries = countries.map{ |code, name| [code.upcase, name] }.sort{ |a, b| a[1] <=> b[1] }
      countries.push([Settings.intntl.other_country.upcase, I18n.t('nonprofits.donate.info.supporter.other_country')]) if Settings.intntl.other_country
      countries
    else
      all_countries.map{ |code, name| [code.upcase, name] }.sort{ |a, b| a[1] <=> b[1] }
    end
  end

end
