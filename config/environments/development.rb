# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
CarrierWave.configure do |config|
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end

Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	config.cache_classes = false
  config.cache_store = Settings.default.cache_store.to_sym

  # Do not eager load code on boot.
  config.eager_load = false
	# Show full error reports and disable caching
	config.consider_all_requests_local = true
	config.action_controller.perform_caching = false

  # You can uncomment the following to test our real AWS email server on localhost:
	# config.action_mailer.delivery_method = :aws_ses
	# config.action_mailer.default_url_options = { host: 'commitchange.com' }
	config.action_mailer.delivery_method = Settings.mailer.delivery_method.to_sym
	config.action_mailer.smtp_settings = { address: Settings.mailer.address, port: Settings.mailer.port }
	config.action_mailer.smtp_settings['user_name']= Settings.mailer.username if Settings.mailer.username
	config.action_mailer.smtp_settings['password']= Settings.mailer.password if Settings.mailer.password

	config.action_mailer.default_url_options = { host: Settings.mailer.host }
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
	# Print deprecation notices to the Rails logger
	config.active_support.deprecation = :log

	# Only use best-standards-support built into browsers
	config.action_dispatch.best_standards_support = :builtin

	# Raise exception on mass assignment protection for Active Record models
	config.active_record.mass_assignment_sanitizer = :strict

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

	# Do not compress assets
	config.assets.compress = false

	# Expands the lines which load the assets
	config.assets.debug = true

	config.assets.digest = true
	# Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

	config.log_level = :debug

	config.dependency_loading = true if $rails_rake_task
	# Turn this on if you want to mess with code inside /node_modules
	# config.browserify_rails.evaluate_node_modules = true

	config.middleware.use I18n::JS::Middleware

end
