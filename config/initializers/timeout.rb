timeout = Integer(ENV['WEB_TIMEOUT'] || 15)
if ENV['RAILS_ENV'] == 'development' || ENV['IDE_PROCESS_DISPATCHER']
  timeout = 10000
end

Rack::Timeout.timeout = timeout  # seconds