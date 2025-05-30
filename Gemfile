# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '6.1.7.10'
gem 'jbuilder', '~> 2.13'
gem 'bootsnap', '~> 1.18', require: false # Large rails application booting enhancer
gem 'hamster', '~> 3.0' # Thread-safe collection classes for Ruby
gem 'puma', '~> 5.6'
gem 'rake'
gem 'sassc-rails', '~> 2.1', '>= 2.1.2'
gem 'sassc', '~> 2.0', '>= 2.0.1'
gem 'stripe', '~> 1.58' # January 19, 2017 version of the Stripe API https://stripe.com/docs/api
gem 'webpacker', '~> 5.4.4'
gem 'good_job', '~> 3.99'

# fix for https://www.ruby-lang.org/en/news/2021/11/15/date-parsing-method-regexp-dos-cve-2021-41817/
gem "date", "~> 3.4.1"

gem 'httparty', '~> 0.22.0' # https://github.com/jnunemaker/httparty
gem 'sprockets', '~> 3.7'

# Helpers
gem 'chronic', '~> 0.10.2' # For nat lang parsing of dates
gem 'countries', '~> 4.2'
gem 'i18n-js', '~> 3.8', git: 'https://github.com/houdiniproject/i18n-js.git', branch: 'houdini-tweaks'
gem 'rails-i18n', '~> 6.0.0', '~> 6'
gem 'premailer-rails', '~> 1.12' # for styling of email
gem 'money', '~> 6.19'

# Database and Events
gem 'pg', '~> 1.5'

gem 'param_validation', path: 'gems/ruby-param-validation'
gem 'qx', path: 'gems/ruby-qx'

# Optimization
gem 'fast_blank'

# Images
gem 'image_processing', '~> 1.13.0'

# URL validation
gem 'validate_url'

# User authentication
# https://github.com/plataformatec/devise
gem 'devise-async', '~> 1.0'
gem 'devise', '~> 4.9'

group :development, :ci do
  gem 'traceroute', '~> 0.8.0'
end

group :development, :ci, :test do
  gem 'debug'
  gem 'dotenv-rails', '~> 2.8', require: 'dotenv/rails-now'
  gem 'rspec-rails', '~> 4.1.2'
  gem 'rspec', '~> 3.13.0'
  gem 'rspec-json_expectations', '~> 2'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'factory_bot', '~> 6.5'
  gem 'listen'
  gem 'table_print', '~> 1.5', '>= 1.5.6' # giuNice table printing of data for the console
  gem 'colorize', '~> 0.8.1' # Print colorized text in debugger/console
  gem 'shoulda-matchers', '~> 5.3.0'
  gem 'turbo_test'
  gem 'erb_lint', require: false
  eval_gemfile './gemfiles/rubocop.gemfile'
end

group :ci, :test do
  gem 'action_mailer_matchers', '~> 1.2'
  gem 'database_cleaner-active_record'
  gem 'stripe-ruby-mock', '~> 2.4.1', require: 'stripe_mock', git: 'https://github.com/commitchange/stripe-ruby-mock.git', branch: '2.4.1'
  gem 'test-unit', '~> 3.6'
  gem 'timecop', '~> 0.9.10'
  gem 'webmock', '~> 3.24'
  gem 'wisper-rspec', '~> 1.1.0'
end

group :production do
  # A user calls `GET /assets/some-css.css` you want the result to be compressed.
  # Normally, you'd use your webserver or some sort of reverse proxy to do so.
  #
  # If your server can't choose to directly serve gzip compressed assets at runtime
  # like heroku, uncomment the `heroku-deflater` line.
  #
  # gem 'heroku-deflater', '~> 0.6.3' # https://github.com/romanbsd/heroku-deflater
  gem 'rack-timeout', '~> 0.7.0'
end

gem 'bess', path: 'gems/bess'

gem 'houdini_full_contact', path: 'gems/houdini_full_contact'

gem "react_on_rails", "12.6.0"

gem 'kaminari'

gem 'http_accept_language'

gem "js-routes"

gem "csv"

gem "concurrent-ruby", "1.3.4" # work around a regression fixed in Rails 7.1
