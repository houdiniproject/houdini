source 'https://rubygems.org'

ruby ENV['CUSTOM_RUBY_VERSION'] || '2.6.10' # heroku needs a specific ruby version in the Gemfile

gem 'rake'
gem 'rails', '~> 4.0'

gem 'rack', git: "https://github.com/CommitChange/rack.git", branch: "1-6-stable"

gem 'date', '~> 2.0.3'

# https://stripe.com/docs/api
gem 'stripe', '~> 4'

# json serialization
# https://github.com/nesquena/rabl
gem 'rabl'

gem 'jbuilder'

gem "puma", "~> 5.6"

gem 'kaminari'

gem 'bootsnap', require: false
gem 'rack-timeout'
gem 'puma_worker_killer'

gem 'test-unit'
gem 'hamster'

gem 'aws-sdk-s3'
gem 'aws-sdk-rails'

gem 'json', '>= 2.3.0'


# for blocking ip addressses
gem 'rack-attack'

# to find middleware thread safety bugs
gem 'rack-freeze'

# Database (postgres)
gem 'pg', "< 1" # Postgresql, must be under 1 because 1.0 and later don't work on Rails 4
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
gem 'carrierwave', '~> 1', '< 2'
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
  gem 'rspec', "~> 3.9"
	gem 'rspec-rails', "~> 3.9"
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

gem 'recaptcha', '~> 5.8.1'

gem 'hashie'

gem 'connection_pool'

gem "barnes"

gem 'protected_attributes' # because we upgraded from 3

gem 'actionpack-action_caching' # because we use action caching

gem 'rack-cors'

gem 'ruby2_keywords' # needed because we're backporting code from Rails 6.2

gem 'securerandom' # needed becuase we're on a pre-2.5 Ruby version

gem 'fx',  git: 'https://github.com/teoljungberg/fx.git', ref: '946cdccbd12333deb8f4566c9852b49c0231a618'

gem 'has_scope'