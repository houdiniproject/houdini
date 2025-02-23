# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  config.cache_store = :mem_cache_store, 
											(ENV["MEMCACHIER_SERVERS"] || "").split(","),
												{:username => ENV["MEMCACHIER_USERNAME"],
												:password => ENV["MEMCACHIER_PASSWORD"],
												:failover => true,
												:socket_timeout => 1.5,
												:socket_failure_delay => 0.2,
												:down_retry_delay => 60,
												:expires_in => 5.hours, :compress => true, pool_size: 10 
											}

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.static_cache_control = "public, max-age=#{10.minutes.seconds.to_i}"

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.digest = true
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

	# Specifies the header that your server uses for sending files
	# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
	config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  	# Enable serving of images, stylesheets, and JavaScripts from an asset server

    cdn_url= URI(Settings.cdn.url)
    cdn_url = cdn_url.to_s
    config.action_controller.asset_host = cdn_url
    config.action_mailer.asset_host = cdn_url
  
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
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.dependency_loading = true if $rails_rake_task

	NONPROFIT_VERIFICATION_SEND_EMAIL_DELAY = 2.hours
end
