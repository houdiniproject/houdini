class MailchimpNonprofitUserJob < ActiveJob::Base
  queue_as :default

  def perform(drip_email_list, user, nonprofit)
    Mailchimp.signup_nonprofit_user(drip_email_list, user, nonprofit)
  end
end
