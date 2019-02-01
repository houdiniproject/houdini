# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

preload_app! if ENV['RAILS_ENV'] != 'development'

rackup      DefaultRackup
port        ENV.fetch("PORT") { 5000 }
environment ENV.fetch('RAILS_ENV'{ 'development' }

workers ENV['WEB_CONCURRENCY'].fetch { 1 }



on_worker_boot do
  # ActiveSupport.on_load(:active_record) do
  #   config = ActiveRecord::Base.configurations[Rails.env] ||
  #       Rails.application.config.database_configuration[Rails.env]
  #   config['pool'] = ENV['RAILS_MAX_THREADS'] || 1
  #   ActiveRecord::Base.establish_connection
  # end
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

