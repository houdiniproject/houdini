# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

	# Log error messages when you accidentally call methods on nil.
	config.whiny_nils = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

	config.action_mailer.delivery_method = :letter_opener
	config.action_mailer.perform_deliveries = true

	config.action_mailer.default_url_options = { host: 'localhost', port: 5000}
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

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true
 
  # Raise exception on mass assignment protection for Active Record models
	config.active_record.mass_assignment_sanitizer = :strict

	# Do not compress assets
	config.assets.compress = false

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.dependency_loading = true if $rails_rake_task
	# Turn this on if you want to mess with code inside /node_modules
	# config.browserify_rails.evaluate_node_modules = true

	config.middleware.use I18n::JS::Middleware

  config.middleware.use Rack::Attack

  NONPROFIT_VERIFICATION_SEND_EMAIL_DELAY = 5.minutes

	ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |name, start, finish, id, payload|
		Rails.logger.debug(payload)

	end
end
