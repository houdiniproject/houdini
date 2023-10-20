# Be sure to restart your server when you modify this file.

if Rails.env.development?
  Rails.application.config.session_store :cookie_store, key: '_commitchange_session'
else
  Rails.application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 12.hours
end
