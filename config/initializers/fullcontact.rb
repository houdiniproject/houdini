# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'fullcontact'

FullContact.configure do |config|
  config.api_key = ENV['FULL_CONTACT_KEY']
end

# see gem docs: https://github.com/fullcontact/fullcontact-api-ruby
