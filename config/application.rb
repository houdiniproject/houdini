# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Commitchange
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets core_ext generators tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "UTC"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Precompile all "page" files
    config.assets.precompile << proc do |path|
      if /.*page\.(css|js)/.match?(path)
        puts "Compiling asset: " + path
        true
      else
        false
      end
    end

    # Version of your assets, change this If you want to expire all your assets
    # config.assets.version = '1.0'

    # For Rails 3.1 on Heroku:
    # Forces the application to not access the DB
    # or load models when precompiling your assets.
    # from: devise gem installation instructions/suggestions
    # config.assets.initialize_on_precompile = true

    config.i18n.enforce_available_locales = false

    # Add trailing slashes to all routes
    # config.action_controller.default_url_options = {:trailing_slash => true}
    #
    # config.browserify_rails.commandline_options = "-t [ babelify --presets es2015 ]"

    # Require `belongs_to` associations by default. Previous versions had false.
    # it's a bunch of work to verify everything that should be marked optional actually is.
    # we should do that over time.
    # Added in rails 5.0
    config.active_record.belongs_to_required_by_default = false

    # just have unknown assets return path like they did before Rails 5.1
    Rails.application.config.assets.unknown_asset_fallback = true

    # keep our forgery protection in ApplicationController, not ActionController::BaseController
    # added in Rails 5.2
    config.action_controller.default_protect_from_forgery = false

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*",
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    config.active_job.queue_adapter = :delayed_job
  end
end
