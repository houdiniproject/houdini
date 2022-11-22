# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
CarrierWave.configure do |config|
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end

Commitchange::Application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	config.eager_load  = false
	config.cache_classes = false
  config.cache_store = :mem_cache_store, 'localhost:11211', {:expires_in => 5.hours, :compress => true, pool_size: 5 }

	# Log error messages when you accidentally call methods on nil.
	config.whiny_nils = true

	# Show full error reports and disable caching
	config.consider_all_requests_local = true
	config.action_controller.perform_caching = false

  # You can uncomment the following to test our real AWS email server on localhost:
	# creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])

	# Aws::Rails.add_action_mailer_delivery_method(
	# 	:ses,
	# 	credentials: creds,
	# 	region: 'us-east-1'
	# )
	# config.action_mailer.delivery_method = :ses

	config.action_mailer.default_url_options = { host: 'localhost', port: 5000}
	config.action_mailer.delivery_method = Settings.mailer.delivery_method.to_sym
	config.action_mailer.smtp_settings = { address: Settings.mailer.address, port: Settings.mailer.port }
        config.action_mailer.smtp_settings['user_name']= Settings.mailer.username if Settings.mailer.username
        config.action_mailer.smtp_settings['password']= Settings.mailer.password if Settings.mailer.password

	# creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])

	# Aws::Rails.add_action_mailer_delivery_method(
	# 	:ses,
	# 	credentials: creds,
	# 	region: 'us-east-1'
	# )
	# config.action_mailer.delivery_method = :ses
	config.action_mailer.default_url_options = { host: 'localhost', port: 5000}

	# Print deprecation notices to the Rails logger
	config.active_support.deprecation = :log

	# Raise exception on mass assignment protection for Active Record models
	config.active_record.mass_assignment_sanitizer = :strict

	# Do not compress assets
	config.assets.compress = false

	# Expands the lines which load the assets
	config.assets.debug = true

	config.assets.quiet = true

	config.log_level = :debug

	config.dependency_loading = true if $rails_rake_task
	# Turn this on if you want to mess with code inside /node_modules
	# config.browserify_rails.evaluate_node_modules = true

	config.middleware.use I18n::JS::Middleware

  config.middleware.use Rack::Attack

  NONPROFIT_VERIFICATION_SEND_EMAIL_DELAY = 5.minutes
end
