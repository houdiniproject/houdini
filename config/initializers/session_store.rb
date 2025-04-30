# Be sure to restart your server when you modify this file.

if Rails.env.development?
  Rails.application.config.session_store :cookie_store, key: "_commitchange_session"
elsif Rails.env.staging? || Rails.env.production?
  Rails.application.config.session_store :redis_store, servers: [ENV["OPENREDIS_URL"]],
    expire_after: 12.hours,
    namespace: "_#{Rails.application.class.module_parent_name.downcase}_session"
else
  Rails.application.config.session_store ActionDispatch::Session::CacheStore, expire_after: 12.hours
end
