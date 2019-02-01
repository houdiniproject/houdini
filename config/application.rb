# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


#require File.expand_path('lib/htp') # Hamster Table Print

module Commitchange
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Custom directories with classes and modules you want to be autoloadable.
		# config.autoload_paths += %W(#{config.root}/extras)
		config.eager_load_paths += Dir["#{config.root}/lib/**/"]

		config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
		config.eager_load_paths += Dir[Rails.root.join('app', 'api', '*')]

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
		config.encoding = "utf-8"

		# Configure sensitive parameters which will be filtered from the log file.
		config.filter_parameters += [:password]

		# Enable escaping HTML in JSON.
		config.active_support.escape_html_entities_in_json = true

		# Use SQL instead of Active Record's schema dumper when creating the database.
		# This is necessary if your schema can't be completely dumped by the schema dumper,
		# like if you have constraints or database-specific column types
		config.active_record.schema_format = :sql

		# Enforce whitelist mode for mass assignment.
		# This will create an empty whitelist of attributes available for mass-assignment for all models
		# in your app. As such, your models will need to explicitly whitelist or blacklist accessible
		# parameters by using an attr_accessible or attr_protected declaration.
		config.active_record.whitelist_attributes = true

		# Enable the asset pipeline
		config.assets.enabled = true

		# Precompile all "page" files
		config.assets.precompile << Proc.new do |path|
			if path =~ /.*page\.(css|js)/
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

		config.active_record.raise_in_transactional_callbacks = true

		# Add trailing slashes to all routes
		# config.action_controller.default_url_options = {:trailing_slash => true}
		#
		# config.browserify_rails.commandline_options = "-t [ babelify --presets es2015 ]"
	end
end
