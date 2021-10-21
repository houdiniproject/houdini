source 'https://rubygems.org'

ruby '2.4.10'
gem 'rake'
gem 'rails', '~> 4.0'

# https://stripe.com/docs/api
gem 'stripe', '~> 4'

# json serialization
# https://github.com/nesquena/rabl
gem 'rabl'

gem 'parallel'

gem "puma", "~> 5.5"

gem 'bootsnap', require: false
gem 'rack-timeout'
gem 'puma_worker_killer'

gem 'test-unit'
gem 'hamster'

gem 'aws-sdk'
gem 'aws-sdk-rails'


# for blocking ip addressses
gem 'rack-attack'

# to find middleware thread safety bugs
gem 'rack-freeze'

# Database (postgres)
gem 'pg' # Postgresql
gem 'qx', path: 'gems/ruby-qx'
gem 'dalli'
gem 'memcachier'


gem 'param_validation', path: 'gems/ruby-param-validation'

# Print colorized text lol
gem 'colorize'

# https://github.com/collectiveidea/delayed_job_active_record
gem 'delayed_job_active_record'

# For nat lang parsing of dates
gem 'chronic'

# Images
# https://github.com/carrierwaveuploader/carrierwave
gem 'carrierwave'
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
gem 'i18n-js'
gem 'countries'


group :development, :ci do
  gem 'traceroute'
end

group :development, :ci, :test do
	gem 'timecop'
	gem 'pry'
	gem 'pry-byebug'
	gem 'binding_of_caller'
  gem 'rspec'
	gem 'rspec-rails'
	gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'ruby-prof', '0.15.9'
	gem 'stripe-ruby-mock', '~> 2.5.1', :require => 'stripe_mock'
  gem 'factory_bot'
	gem 'factory_bot_rails'
	gem 'action_mailer_matchers', '~> 1.2.0'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'byebug'
  gem 'shoulda-matchers'
end

group :test do
  gem 'webmock'
end

# Gems used for asset compilation
gem 'sass'
gem 'sass-rails'

# make logging less terrible in rails
gem 'lograge'

gem 'config', '> 1.5'
gem 'dry-validation' # used only for config validation

gem 'foreman'



group :production do
  gem 'rails_autoscale_agent', '>= 0.9.1'
  gem 'tunemygc'
end


group :production, :staging do
  gem 'heroku_rails_deflate'
  gem "hiredis", "~> 0.6.0"
  gem "redis", ">= 3.2.0"
  gem 'redis-actionpack'
  gem 'rails_12factor'
end

gem 'grape', '~> 1.1.0'
gem 'grape-entity', git: 'https://github.com/ruby-grape/grape-entity.git', ref: '0e04aa561373b510c2486282979085eaef2ae663'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape_url_validator'
gem 'grape_logging'
gem 'grape_devise', path: 'gems/grape_devise'

gem 'recaptcha', '~> 5.8.1'

gem 'hashie'

gem 'connection_pool'

gem "barnes"

gem 'protected_attributes' # because we upgraded from 3

gem 'actionpack-action_caching' # because we use action caching

gem 'rack-cors'