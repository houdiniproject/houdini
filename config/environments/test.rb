# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Commitchange::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.eager_load  = false
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.delivery_method = :test
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { host: 'localhost:8080' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.log_level = :debug

  config.action_controller.allow_forgery_protection = false
  config.cache_store = :memory_store

  ENV['THROTTLE_SUPPORTER_LIMIT'] = '10'
  ENV['THROTTLE_SUPPORTER_PERIOD'] = '60'

  config.after_initialize do
    # ActiveRecord::Base.logger = nil
    # ActionController::Base.logger =  nil
    # ActionMailer::Base.logger = nil
  end
  config.middleware.use Rack::Attack


  NONPROFIT_VERIFICATION_SEND_EMAIL_DELAY = 2.hours
end
