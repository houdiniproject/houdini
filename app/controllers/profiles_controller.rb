# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ProfilesController < ApplicationController
  helper_method :authenticate_profile_owner!

  before_action :authenticate_profile_owner!, only: [:update, :fundraisers, :donations_history]

  # get /profiles/:id
  # public profile
  def show
    @profile = Profile.find(params[:id])
    @profile_nonprofits = Psql.execute(Qexpr.new.select("DISTINCT nonprofits.*").from(:nonprofits).join(:supporters, "supporters.nonprofit_id=nonprofits.id AND supporters.profile_id=#{@profile.id}"))
    @campaigns = @profile.campaigns.published.includes(:nonprofit)
    if @profile.anonymous? && current_user_id != @profile.user_id && !current_role?(:super_admin)
      flash[:notice] = "That user does not have a public profile."
      redirect_to(root_url)
      nil
    end
  end

  # get /profiles/:id/donations_history
  def donations_history
    validate
    @profile = Profile.find(params[:id])
    @recurring_donations = @profile.recurring_donations.where(active: true).includes(:nonprofit)
    @donations = @profile.donations.includes(:nonprofit)
  end

  # get /profiles/:id/fundraisers
  def fundraisers
    validate
    current_user = Profile.find(params[:id]).user
    @profile = current_user.profile
    @edited_campaigns = Campaign.where("profile_id=#{@profile.id}").order("end_datetime DESC")
  end

  # get /profiles/:id/events
  def events
    render json: QueryEventMetrics.for_listings("profile", params[:id], params)
  end

  # put /profiles/:id
  def update
    @profile = if current_role?(:super_admin) # can update other profiles
      Profile.find(params[:id])
    else
      current_user.profile
    end
    @profile.update_attributes(params[:profile])
    json_saved @profile, "Profile updated"
  end

  private

  def authenticate_profile_owner!
    if !current_role?(:super_associate) &&
        !current_role?(:super_admin) &&
        (!current_user ||
            !current_user.profile ||
            current_user.profile.id != params[:id].to_i)
      block_with_sign_in
    end
  end

  def validate
    if !current_role?(:super_admin) && current_user.profile.id != params[:id].to_i
      flash[:notice] = "Sorry, you don't have access to that page"
      redirect_to root_url
    end
  end
end
