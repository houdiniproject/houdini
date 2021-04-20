# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Commitchange::Application.configure do
	# Settings specified here will take precedence over those in config/application.rb

	# Code is not reloaded between requests
	config.eager_load  = true
	config.cache_classes = true
  config.cache_store = Settings.default.cache_store.to_sym, nil, {:expires_in => 5.hours, :compress => true, pool_size: 10 }

	config.session_store :redis_store, servers: [ENV['OPENREDIS_URL']], 
		expire_after: 12.hours,
		namespace: "_#{Rails.application.class.parent_name.downcase}_session"

	# Full error reports are disabled and caching is turned on
	config.consider_all_requests_local = false
	config.action_controller.perform_caching = true

	# Disable Rails's static asset server (Apache or nginx will already do this)
	config.serve_static_assets = true
	config.static_cache_control = "public, max-age=86400"

	# Compress JavaScripts and CSS
	config.assets.compress = true

	# Generate digests for assets URLs
	config.assets.digest = true
  config.assets.compile = false

	# Defaults to nil and saved in location specified by config.assets.prefix
	# config.assets.manifest = YOUR_PATH

	# Specifies the header that your server uses for sending files
	# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
	config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

	# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
	config.force_ssl = true

	# See everything in the log (default is :info)
	config.log_level = :debug

	# Prepend all log lines with the following tags
	# config.log_tags = [ :subdomain, :uuid ]

	# Use a different logger for distributed setups
	# config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

	# Use a different cache store in production
	# config.cache_store = :mem_cache_store

	# Enable serving of images, stylesheets, and JavaScripts from an asset server

  cdn_url= URI(Settings.cdn.url)
  cdn_url = cdn_url.to_s
	config.action_controller.asset_host = cdn_url
	config.action_mailer.asset_host = cdn_url
	config.font_assets.origin = '*'

	# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
	creds = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])

	Aws::Rails.add_action_mailer_delivery_method(
		:ses,
		credentials: creds,
		region: 'us-east-1'
	)
	# Disable delivery errors, bad email addresses will be ignored
	# config.action_mailer.raise_delivery_errors = false
	config.action_mailer.delivery_method = :ses
	config.action_mailer.default_url_options = { host: Settings.mailer.host }
        # Precompile all "page" files, it needs to be set here so the proper env is setup
        config.assets.precompile << Proc.new do |path|
	  if path =~ /.*page\.(css|js)/
	    puts "Compiling asset: " + path
            true
          else
            false
          end
        end


	# Enable locale fallbacks for I18n (makes lookups for any locale fall back to
	# the I18n.default_locale when a translation can not be found)
	config.i18n.fallbacks = true

	# Send deprecation notices to registered listeners
	config.active_support.deprecation = :notify

	# Log the query plan for queries taking more than this (works
	# with SQLite, MySQL, and PostgreSQL)
	# config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.assets.compile = false

	config.dependency_loading = true if $rails_rake_task
	# Compress json
  #config.middleware.use Rack::Deflater
	config.middleware.insert_before 'Rack::Cache', Rack::Attack
	NONPROFIT_VERIFICATION_SEND_EMAIL_DELAY = 2.hours
	# remove auto explain threshold
	config.active_record.auto_explain_threshold_in_seconds = nil
end
