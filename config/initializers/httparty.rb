# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'httparty'
::HTTParty::Logger.add_formatter(:mailchimp, ::Httparty::Logger::MailchimpLogger)
::HTTParty::Logger.add_formatter(:full_contact, ::Httparty::Logger::FullContactLogger)
