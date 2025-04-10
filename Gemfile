source 'https://rubygems.org'

ruby ENV['CUSTOM_RUBY_VERSION'] || '3.0.7' # heroku needs a specific ruby version in the Gemfile

gem 'rake'
gem 'rails', '~> 7.0.8.7'
gem 'sprockets', '~> 3.7' # Sprockets 4.0 stops allowing us to add a proc to the config.assets.precompile array, which we currently use

gem 'rack', '~> 2.2.13'

# https://stripe.com/docs/api
gem 'stripe', '~> 5.0'

# json serialization
# https://github.com/nesquena/rabl
gem 'rabl'

gem 'jbuilder'

gem "puma", "~> 5.6"

gem 'kaminari'

gem 'bootsnap', require: false
gem 'rack-timeout'

gem 'test-unit'
gem 'hamster'

gem 'aws-sdk-s3'
gem 'aws-sdk-rails'

gem 'json', '>= 2.3.0'

gem 'yaaf' # form objects

# for blocking ip addressses
gem 'rack-attack'

# to find middleware thread safety bugs
gem 'rack-freeze'

# Database (postgres)
gem 'pg', '~> 1.1'
gem 'qx', path: 'gems/ruby-qx'
gem 'dalli'


gem 'param_validation', path: 'gems/ruby-param-validation'

# Print colorized text lol
gem 'colorize'

# https://github.com/collectiveidea/delayed_job_active_record
gem 'delayed_job_active_record'

# For nat lang parsing of dates
gem 'chronic'

# Images
# https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave', '~> 3.0'
gem 'carrierwave-aws' # for uploading images to amazon s3
gem 'mini_magick'

# https://github.com/jnunemaker/httparty
gem 'httparty'

# User authentication
# https://github.com/plataformatec/devise
gem 'devise', '~> 4.1'

# https://github.com/airbrake/airbrake
gem 'airbrake'

# http://www.rubygeocoder.com/
gem 'geocoder' # for adding latitude and longitude to location-based tables

# https://github.com/buytruckload/nearest_time_zone
gem 'nearest_time_zone' # for detecting timezone from lat/lng

gem 'rest-client' # recommended for fullcontact

# https://github.com/fphilipe/premailer-rails
# for stylizing emails
gem 'premailer-rails'

# Nice table printing of data for the console
gem 'table_print'

gem 'rails-i18n' # For 4.0.x
gem 'i18n-js', '~> 3.8' # i18n-js 4 is very different and doesn't work without some big changes
gem 'countries'

gem 'rexml' # needed on Ruby 3

group :development, :ci, :test do
  gem 'listen'
  gem 'letter_opener'
	gem 'timecop'
	gem 'pry'
	gem 'pry-byebug'
	gem 'binding_of_caller'
  gem 'rspec', "~> 3"
	gem 'rspec-rails', "~> 6"
	gem 'database_cleaner'
  gem 'dotenv-rails'
	gem 'stripe-ruby-mock', '~> 3.0', :require => 'stripe_mock'
  gem 'factory_bot'
	gem 'factory_bot_rails'
	gem 'action_mailer_matchers', '~> 1.2.0'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'byebug'
  gem 'shoulda-matchers'
  gem 'rspec-json_expectations'
  gem 'yard'
  gem 'faker' # test data generation
end


group :test do
  gem 'webmock'
end

# Gems used for asset compilation
gem 'sassc'
gem 'sassc-rails'

# make logging less terrible in rails
gem 'lograge'

gem 'config', '~> 2.0'
gem 'dry-validation' # used only for config validation

group :production do
  gem 'rails_autoscale_agent', '>= 0.9.1'
  gem 'tunemygc'
end


group :production, :staging do
  gem "hiredis", "~> 0.6.0"
  gem "redis", ">= 3.2.0"
  gem 'redis-actionpack'
end

gem 'recaptcha', '~> 5.8.1'

gem 'hashie'

gem 'connection_pool'

gem "barnes"

gem 'protected_attributes_continued' # because we upgraded from 3 and then 4

gem 'actionpack-action_caching' # because we use action caching

gem 'rack-cors'

gem 'fx'

gem 'has_scope'

gem 'globalid', ">= 1.0.1"

gem 'js-routes'

gem 'concurrent-ruby', '1.3.4' # there's a regression in 1.3.5 that can be removed at Rails 7.1
