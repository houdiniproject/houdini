# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Commitchange::Application.configure do
<<<<<<< HEAD
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.cache_store = Settings.default.cache_store.to_sym

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

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

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works)
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.log_level = :debug

  config.threadsafe!
  config.dependency_loading = true if $rails_rake_task
  # Turn this on if you want to mess with code inside /node_modules
  # config.browserify_rails.evaluate_node_modules = true

  config.middleware.use I18n::JS::Middleware

  config.after_initialize do
    ActiveRecord::Base.logger = nil
  end

end
