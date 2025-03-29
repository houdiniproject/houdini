# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'httparty'

# runs once on boot but won't reload the classes when they change
Rails.application.config.after_initialize do
  ::HTTParty::Logger.add_formatter(:mailchimp, ::Httparty::Logger::MailchimpLogger)
  ::HTTParty::Logger.add_formatter(:full_contact, ::Httparty::Logger::FullContactLogger)
end
