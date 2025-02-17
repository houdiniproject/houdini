# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: ENV["COOKIE_STORE_KEY"] || "_commitchange_session"
