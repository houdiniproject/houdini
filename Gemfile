source 'https://rubygems.org'

ruby '2.3.8'
gem 'rake'
gem 'rails', '3.2.22.5'
gem 'rails_12factor'
# https://stripe.com/docs/api
gem 'stripe'

# json serialization
# https://github.com/nesquena/rabl
gem 'rabl'

gem 'parallel'

gem "puma", ">= 3.12.2"

gem 'bootsnap', require: false
gem 'rack-timeout'
gem 'puma_worker_killer'

gem 'test-unit', '~> 3.0'
gem 'hamster'

gem 'aws-ses'
gem 'aws-sdk'

# for blocking ip addressses
gem 'rack-attack'

# For modularizing javascript
# https://github.com/browserify-rails/browserify-rails
gem 'browserify-rails'
gem 'sprockets'

# for serving fonts on cdn
# https://github.com/ericallam/font_assets
gem 'font_assets', "~> 0.1.14"

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

# for styling emails
# https://github.com/Mange/roadie-rails
gem 'roadie-rails'

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
gem 'devise'
gem 'devise-async'

# https://github.com/airbrake/airbrake
gem 'airbrake', '~> 6.2.1'

# http://www.rubygeocoder.com/
gem 'geocoder' # for adding latitude and longitude to location-based tables

# https://github.com/buytruckload/nearest_time_zone
gem 'nearest_time_zone' # for detecting timezone from lat/lng

gem 'mail_view'

gem 'rest-client' # recommended for fullcontact

# Nice table printing of data for the console
gem 'table_print'

gem 'bunny', '>= 2.6.3'

gem 'rails-i18n', '~> 3.0.0' # For 3.x
gem 'i18n-js'
gem 'countries'


group :development, :ci do
  gem 'traceroute'
  gem 'debase', '~> 0.2.3'
  gem 'ruby-debug-ide'
end

group :development, :ci, :test do
	gem 'timecop'
	gem 'pry'
	#gem 'pry-byebug'
	gem 'binding_of_caller'
  gem 'rspec'
	gem 'rspec-rails'
	gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'ruby-prof', '0.15.9'
	gem 'stripe-ruby-mock', '~> 2.4.1', :require => 'stripe_mock', git: 'https://github.com/commitchange/stripe-ruby-mock.git', :branch => '2.4.1'
  gem 'factory_bot'
	gem 'factory_bot_rails'
	gem 'action_mailer_matchers'
  gem 'simplecov', '~> 0.16.1', require: false
  gem 'byebug'
end

group :test do
  gem 'webmock'
end

# Gems used for asset compilation
gem 'sass', '3.2.19'
gem 'sass-rails', '3.2.6'
gem 'uglifier'

# make logging less terrible in rails
gem 'lograge'

gem 'config', '> 1.5'
gem 'dry-validation' # used only for config validation

gem 'foreman'



group :production do
  gem 'rails_autoscale_agent'
end


group :production, :staging do
  gem 'heroku_rails_deflate'
end

gem 'grape', '~> 1.1.0'
gem 'grape-entity', git: 'https://github.com/ruby-grape/grape-entity.git', ref: '0e04aa561373b510c2486282979085eaef2ae663'
gem 'grape-swagger'
gem 'grape-swagger-entity'
gem 'grape_url_validator'
gem 'grape_logging'
gem 'grape_devise', path: 'gems/grape_devise'

gem 'recaptcha', path: 'gems/recaptcha'

gem 'rbtrace'