class MailchimpNonprofitUserJob < ActiveJob::Base
  queue_as :default

  def perform(user, nonprofit)
    Mailchimp.signup_nonprofit_user(user, nonprofit)
  end
end
