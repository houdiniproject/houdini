# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Be sure to restart your server when you modify this file.

Commitchange::Application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 4.hours

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Commitchange::Application.config.session_store :active_record_store
