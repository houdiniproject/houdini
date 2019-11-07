class SupporterFundraiserCreateJob < ApplicationJob
  queue_as :default

  def perform(fundraiser)
    NonprofitAdminMailer.supporter_fundraiser(fundraiser).deliver_now
  end
end
