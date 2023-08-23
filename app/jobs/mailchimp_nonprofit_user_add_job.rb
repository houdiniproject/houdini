# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class MailchimpNonprofitUserAddJob < ActiveJob::Base
  queue_as :default

  def perform(user, nonprofit)
    Mailchimp.signup_nonprofit_user(DripEmailList.first, user, nonprofit)
  end
end
