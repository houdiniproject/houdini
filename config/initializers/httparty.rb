# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

Rails.application.config.after_initialize do
  ::HTTParty::Logger.add_formatter(:mailchimp, ::HTTParty::Logger::MailchimpLogger)
  ::HTTParty::Logger.add_formatter(:full_contact, ::HTTParty::Logger::FullContactLogger)
end
