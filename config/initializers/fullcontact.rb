require "fullcontact"

FullContact.configure do |config|
	config.api_key = ENV['FULL_CONTACT_KEY']
end

# see gem docs: https://github.com/fullcontact/fullcontact-api-ruby