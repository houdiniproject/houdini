# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.7.2'
gem 'rails', '~> 6.1.3'
gem 'jbuilder', '~> 2.10'
gem 'bootsnap', '~> 1.4', require: false # Large rails application booting enhancer
gem 'font_assets', '~> 0.1.14' # for serving fonts on cdn https://github.com/ericallam/font_assets
gem 'hamster', '~> 3.0' # Thread-safe collection classes for Ruby
gem 'puma', '~> 5.0'
gem 'rake', '~> 12.3.2'
gem 'sassc-rails', '~> 2.1', '>= 2.1.2'
gem 'sassc', '~> 2.0', '>= 2.0.1'
gem 'stripe', '~> 1.58' # January 19, 2017 version of the Stripe API https://stripe.com/docs/api
gem 'webpacker', '~> 5.2.1'
gem 'react-rails'
gem 'good_job'

gem 'httparty', '~> 0.17.0' # https://github.com/jnunemaker/httparty
gem 'rack-attack', '~> 5.2' # for blocking ip addressses
gem 'rack-ssl', '~> 1.4'
gem 'sprockets', '~> 3.7'

# Helpers
gem 'chronic', '~> 0.10.2' # For nat lang parsing of dates
gem 'countries', '~> 3.0'
gem 'i18n-js', '~> 3.8', git: 'https://github.com/houdiniproject/i18n-js.git', branch: 'houdini-tweaks'
gem 'lograge', '~> 0.11.2' # make logging less terrible in rails
gem 'rails-i18n', '~> 6.0.0', '~> 6'
gem 'roadie-rails', '~> 2.1' # email generation helpers
gem 'money', '~> 6.13'

# Database and Events
gem 'pg', '~> 1.1'

gem 'param_validation', path: 'gems/ruby-param-validation'
gem 'qx', path: 'gems/ruby-qx'

# Optimization
gem 'fast_blank'

# Images
gem 'image_processing', '~> 1.10.3'

# User authentication
# https://github.com/plataformatec/devise
gem 'devise-async', '~> 1.0'
gem 'devise', '~> 4.7'

group :development, :ci do
  gem 'traceroute', '~> 0.8.0'
end

group :development, :ci, :test do
  gem 'byebug', '~> 11.0', '>= 11.0.1'
  gem 'dotenv-rails', '~> 2.7', '>= 2.7.5', require: 'dotenv/rails-now'
  gem 'mail_view', '~> 2.0'
  gem 'pry', '~> 0.12.2'
  gem 'pry-byebug', '~> 3.7.0'
  gem 'rspec-rails', '~> 4.0.0'
  gem 'rspec', '~> 3.9.0'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  gem 'factory_bot', '~> 5.0', '>= 5.0.2'
  gem 'listen'
  gem 'table_print', '~> 1.5', '>= 1.5.6' # giuNice table printing of data for the console
  gem 'colorize', '~> 0.8.1' # Print colorized text in debugger/console
  gem 'rubocop', '~> 1.10'
  gem 'rubocop-rails', '~> 2.9'
  gem 'rubocop-rake', '~> 0.5.1'
  gem 'rubocop-rspec', '~> 2.2'
end

group :ci, :test do
  gem 'action_mailer_matchers', '~> 1.2'
  gem 'database_cleaner-active_record'
  gem 'stripe-ruby-mock', '~> 2.4.1', require: 'stripe_mock', git: 'https://github.com/commitchange/stripe-ruby-mock.git', branch: '2.4.1'
  gem 'test-unit', '~> 3.3'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.6', '>= 3.6.2'
  gem 'wisper-rspec', '~> 1.1.0'
end

group :production do
  # Compression of assets on heroku
  # https://github.com/romanbsd/heroku-deflater
  gem 'heroku-deflater', '~> 0.6.3'
  gem 'rack-timeout', '~> 0.5.1'
end

gem 'bess', path: 'gems/bess'

gem 'houdini_full_contact', path: 'gems/houdini_full_contact'
