# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# set the Rack timeout to 2 hours when running in development so we can use breakpoints
# For staging and prod, you should set the RACK_TIMEOUT_SERVICE_TIMEOUT environment variable
if Rails.env.development? || ENV["IDE_PROCESS_DISPATCHER"]
  ENV["RACK_TIMEOUT_SERVICE_TIMEOUT"] = 2.hours.to_s
end

if Rails.env.local?
  Rack::Timeout::Logger.disable # quiet logs in dev
end
