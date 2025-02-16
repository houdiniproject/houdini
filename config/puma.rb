# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'barnes'
workers Integer(ENV['WEB_CONCURRENCY'] || 1)
threads_count = Integer(ENV['MAX_THREADS'] || 5)


threads threads_count, threads_count


preload_app! if ENV['RAILS_ENV'] != 'development'

rackup      DefaultRackup
port        ENV['PORT']     || 5000
environment ENV['RAILS_ENV'] || 'development'



on_worker_boot do
  ActiveRecord::Base.establish_connection
end

before_fork do
  Barnes.start
end

# rackup      DefaultRackup
# port        ENV['PORT']     || 8080
# environment ENV['RAILS_ENV'] || 'development'
# tag 'commitchange'
# # workers 2
# daemonize
#
# # Read environment
# require 'dotenv'
# Dotenv.load ".env"
# @env = ENV['RAILS_ENV']
# # || 'development'
# Dotenv.load ".env.#{@env}"
# puts ENV['PORT']
# puts "----------------------- #{@env} -----------------------------------"
# @dir = ENV['PUMADIR'] || ENV['PWD']
# @port = ENV['PORT'] || 10525
#
# workers Integer(ENV['WEB_CONCURRENCY'] || 1)
# threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 1)
# preload_app! if ENV['RAILS_ENV'] != 'development'
#
# if heroku?
#   threads threads_count, threads_count
# else
#   threads 1, threads_count
# end
#
# environment @env || 'development'
# #environment 'production'
#
# before_fork do
#   require 'puma_worker_killer'
#   PumaWorkerKiller.enable_rolling_restart # Default is every 6 hours
# end
#
# tmp_dir = File.expand_path("./tmp", @dir)
# log_dir = File.expand_path("./log", @dir)
#
# if @port
#   port @port
# else
#   bind "unix://#{tmp_dir}/sockets/puma.sock"
# end
#
# unless heroku?
#   # Pid files
#   pidfile "#{tmp_dir}/pids/puma.pid"
#   state_path "#{tmp_dir}/pids/puma.state"
#
#   # Logging
#
#   if ENV['LOG_TO_FILES']
#     puts "log to files #{log_dir}/puma.[stdout|stderr].#{@env}.log"
#     stdout_redirect "#{log_dir}/puma.stdout.#{@env}.log", "#{log_dir}/puma.stderr.#{@env}.log", true
#   end
# end
# on_worker_boot do
#   ActiveSupport.on_load(:active_record) do
#     config = ActiveRecord::Base.configurations[Rails.env] ||
#         Rails.application.config.database_configuration[Rails.env]
#     config['pool'] = ENV['RAILS_MAX_THREADS'] || 1
#     ActiveRecord::Base.establish_connection
#   end
# end


