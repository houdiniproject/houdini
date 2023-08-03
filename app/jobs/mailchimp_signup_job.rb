# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MailchimpSignupJob < ApplicationJob
  queue_as :default

  def perform(supporter, mailchimp_list)
    Mailchimp.signup(supporter, mailchimp_list)
  end
end
