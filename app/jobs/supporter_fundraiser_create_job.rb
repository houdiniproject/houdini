class SupporterFundraiserCreateJob < ApplicationJob
  queue_as :default

  def perform(fundraiser)
    NonprofitAdminMailer.supporter_fundraiser(fundraiser).deliver_now unless QueryRoles.is_nonprofit_user?(fundraiser.profile.user.id, fundraiser.nonprofit.id)
  end
end
