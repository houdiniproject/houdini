# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "good_job/engine"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# require File.expand_path('lib/htp') # Hamster Table Print
module Commitchange
  class Application < Rails::Application
    config.load_defaults '5.0'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.eager_load_paths += Dir["#{config.root}/lib/**/", ""]

    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.paths.add File.join('app', 'listeners'), glob: File.join('**', '*.rb')
    # config.eager_load_paths += Dir[Rails.root.join('app', 'api', '*'), Rails.root.join('app', 'listeners', '*')]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :ruby

    # Enable the asset pipeline
    config.assets.enabled = true

    # Precompile all "page" files
    config.assets.precompile << proc do |path|
      if /.*page\.(css|js)/.match?(path)
        puts 'Compiling asset: ' + path
        true
      else
        false
      end
    end

    # add fonts to assets pipeline
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

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

    # we don't require belongs_to associations to be required for historical reasons.
    config.active_record.belongs_to_required_by_default = false

    config.active_storage.variant_processor = :vips

    config.action_mailer.default_options = {from: "Default Org Team <hi@defaultorg.com>"}

    config.active_storage.draw_routes = false

    config.active_job.queue_adapter = :good_job

    # this works around a bug where the the webpacker proxy
    # only waits 60 seconds for a compilation to happen. That's not 
    # fast enough on startup and Webpacker doesn't allow us to override.
    # 
    # TODO: figure out how to delete the first instance of DevServerProxy
    initializer "houdini.webpacker.proxy" do |app|
      insert_middleware = Webpacker.config.dev_server.present? rescue nil
      if insert_middleware
        app.middleware.insert_before 0,
             Webpacker::DevServerProxy, ssl_verify_none: true, read_timeout: 500
      end
    end
  end
end
