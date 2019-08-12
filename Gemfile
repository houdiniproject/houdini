# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.5.1'
gem 'rails', '~> 5.2.3'
gem 'bootsnap', '~> 1.4', require: false # Large rails application booting enhancer
gem 'delayed_job_active_record', '~> 4.1'
gem 'font_assets', '~> 0.1.14' # for serving fonts on cdn https://github.com/ericallam/font_assets
gem 'hamster', '~> 3.0' # Thread-safe collection classes for Ruby
gem 'parallel', '~> 1.17' # run processes in parallel
gem 'puma_worker_killer', '~> 0.1.1' # TODO: Investigate why puma workers need to be killed.
gem 'puma', '~> 4.0', '>= 4.0.1'
gem 'rabl', '~> 0.14.1' # JSON serialization https://github.com/nesquena/rabl
gem 'rake', '~> 12.3.2'
gem 'sassc-rails', '~> 2.1', '>= 2.1.2'
gem 'sassc', '~> 2.0', '>= 2.0.1'
gem 'stripe', '~> 1.58' # January 19, 2017 version of the Stripe API https://stripe.com/docs/api
gem 'uglifier', '~> 4.1', '>= 4.1.20'
gem 'ffi', '~> 1.11', '>= 1.11.1'

gem 'httparty', '~> 0.17.0' # https://github.com/jnunemaker/httparty
gem 'rack-attack', '~> 5.2' # for blocking ip addressses
gem 'rack-ssl', '~> 1.4'
gem 'sprockets', '~> 3.7'

# AWS services
gem 'aws-sdk', '~> 1.67'
gem 'aws-ses', '~> 0.6.0' # REST email integration API
gem 'carrierwave-aws', '~> 1.3' # for uploading images to amazon s3

# External Services
gem 'fullcontact', '~> 0.18.0' # Full Contact API; includes #Hashie::Mash

# Helpers
gem 'chronic', '~> 0.10.2' # For nat lang parsing of dates
gem 'colorize', '~> 0.8.1' # Print colorized text in debugger/console
gem 'countries', '~> 3.0'
gem 'geocoder', '~> 1.5' # for adding latitude and longitude to location-based tables http://www.rubygeocoder.com/
gem 'i18n-js', '~> 3.3'
gem 'lograge', '~> 0.11.2' # make logging less terrible in rails
gem 'nearest_time_zone', '~> 0.0.4' # for detecting timezone from lat/lng https://github.com/buytruckload/nearest_time_zone
gem 'rails-i18n', '~> 5.1', '>= 5.1.3'
gem 'roadie-rails', '~> 2.1' # email generation helpers
gem 'table_print', '~> 1.5', '>= 1.5.6' # Nice table printing of data for the console

# Database and Events
gem 'bunny', '~> 2.14', '>= 2.14.2' # RabittMQ
gem 'dalli', '~> 2.7'
gem 'memcachier', '~> 0.0.2'
gem 'pg', '~> 0.11'

gem 'param_validation', path: 'gems/ruby-param-validation'
gem 'qx', path: 'gems/ruby-qx'

# Images
gem 'carrierwave', '~> 1.3' # https://github.com/carrierwaveuploader/carrierwave
gem 'mini_magick', '~> 4.9'

# User authentication
# https://github.com/plataformatec/devise
gem 'devise-async', '~> 1.0'
gem 'devise', '~> 4.4'

# API Tools
gem 'config', '> 1.5'
gem 'dry-validation', '~> 0.13.3' # used only for config validation
gem 'foreman', '~> 0.85.0'
gem 'grape_devise', path: 'gems/grape_devise'
gem 'grape_logging', '~> 1.8', '>= 1.8.1'
gem 'grape_url_validator', '~> 1.0'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger-entity', '~> 0.3.3'
gem 'grape-swagger', '~> 0.33.0'
gem 'grape', '~> 1.2', '>= 1.2.4'

group :development do
  gem 'grape_on_rails_routes', '~> 0.3.2'
end

group :development, :ci do
  gem 'debase', '~> 0.2.3'
  gem 'ruby-debug-ide', '~> 0.7.0'
  gem 'traceroute', '~> 0.8.0'
end

group :development, :ci, :test do
  gem 'binding_of_caller', '~> 0.8.0'
  gem 'byebug', '~> 11.0', '>= 11.0.1'
  gem 'dotenv-rails', '~> 2.7', '>= 2.7.5'
  gem 'mail_view', '~> 2.0'
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug', '~> 3.7.0'
  gem 'ruby-prof', '0.15.9'
  gem 'solargraph', '~> 0.35.1'
  gem 'standard', '~> 0.1.2'
end

group :ci, :test do
  gem 'action_mailer_matchers', '~> 1.2'
  gem 'database_cleaner', '~> 1.7'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  gem 'factory_bot', '~> 5.0', '>= 5.0.2'
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'rspec', '~> 3.8'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'stripe-ruby-mock', '~> 2.4.1', require: 'stripe_mock', git: 'https://github.com/commitchange/stripe-ruby-mock.git', branch: '2.4.1'
  gem 'test-unit', '~> 3.3'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.6', '>= 3.6.2'
end

group :production do
  # Compression of assets on heroku
  # https://github.com/romanbsd/heroku-deflater
  gem 'heroku-deflater', '~> 0.6.3'
  gem 'rack-timeout', '~> 0.5.1'
end
