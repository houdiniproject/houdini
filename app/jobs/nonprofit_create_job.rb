class NonprofitCreateJob < ApplicationJob
  queue_as :default

  def perform(nonprofit)
    NonprofitMailer.welcome(nonprofit.id).deliver
  end
end
