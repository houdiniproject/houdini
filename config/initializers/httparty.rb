# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'httparty'
require 'httparty/logger/mailchimp_logger'
require 'httparty/logger/full_contact_logger'
::HTTParty::Logger.add_formatter(:mailchimp, HTTParty::Logger::MailchimpLogger)
::HTTParty::Logger.add_formatter(:full_contact, HTTParty::Logger::FullContactLogger)
