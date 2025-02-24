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


