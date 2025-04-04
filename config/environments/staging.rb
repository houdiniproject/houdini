# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require_relative './production'

Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb and config/environments/production.rb

	config.default_url_options = { host: 'commitchange-test.herokuapp.com' }
	config.action_mailer.delivery_method = Settings.mailer.delivery_method.to_sym
	config.action_mailer.default_url_options = config.default_url_options

	# we want to be able to show mailer previews
	config.action_mailer.show_previews = true
end
