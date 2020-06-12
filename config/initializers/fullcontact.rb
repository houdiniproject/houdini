# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'fullcontact'

FullContact.configure do |config|
  config.api_key = ENV['FULL_CONTACT_KEY']
end

# see gem docs: https://github.com/fullcontact/fullcontact-api-ruby
