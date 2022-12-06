# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '6.1.7'
gem 'jbuilder', '~> 2.11'
gem 'bootsnap', '~> 1.15', require: false # Large rails application booting enhancer
gem 'hamster', '~> 3.0' # Thread-safe collection classes for Ruby
gem 'puma', '~> 5.6'
gem 'rake', '~> 12.3.2'
gem 'sassc-rails', '~> 2.1', '>= 2.1.2'
gem 'sassc', '~> 2.0', '>= 2.0.1'
gem 'stripe', '~> 1.58' # January 19, 2017 version of the Stripe API https://stripe.com/docs/api
gem 'webpacker', '~> 5.4.3'
gem 'good_job', '~> 3.6'
gem 'net-http'
gem 'net-smtp'
gem 'net-imap'
gem 'uri', '0.10.0'

# fix for https://www.ruby-lang.org/en/news/2021/11/15/date-parsing-method-regexp-dos-cve-2021-41817/
gem "date", "~> 3.3.0"

gem 'httparty', '~> 0.20.0' # https://github.com/jnunemaker/httparty
gem 'rack-attack', '~> 5.2' # for blocking ip addressses
gem 'rack-ssl', '~> 1.4'
gem 'sprockets', '~> 3.7'

# Helpers
gem 'chronic', '~> 0.10.2' # For nat lang parsing of dates
gem 'countries', '~> 4.2'
gem 'i18n-js', '~> 3.8', git: 'https://github.com/houdiniproject/i18n-js.git', branch: 'houdini-tweaks'
gem 'lograge', '~> 0.12.0' # make logging less terrible in rails
gem 'rails-i18n', '~> 6.0.0', '~> 6'
gem 'premailer-rails', '~> 1.12' # for styling of email
gem 'money', '~> 6.16'

# Database and Events
gem 'pg', '~> 1.4'

gem 'param_validation', path: 'gems/ruby-param-validation'
gem 'qx', path: 'gems/ruby-qx'

# Optimization
gem 'fast_blank'

# Images
gem 'image_processing', '~> 1.12.2'

# URL validation
gem 'validate_url'

# User authentication
# https://github.com/plataformatec/devise
gem 'devise-async', '~> 1.0'
gem 'devise', '~> 4.8'

group :development, :ci do
  gem 'traceroute', '~> 0.8.0'
end

group :development, :ci, :test do
  gem 'debug'
  gem 'dotenv-rails', '~> 2.8', require: 'dotenv/rails-now'
  gem 'rspec-rails', '~> 4.1.2'
  gem 'rspec', '~> 3.12.0'
  gem 'rspec-json_expectations', '~> 2'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'factory_bot', '~> 6.2'
  gem 'listen'
  gem 'table_print', '~> 1.5', '>= 1.5.6' # giuNice table printing of data for the console
  gem 'colorize', '~> 0.8.1' # Print colorized text in debugger/console
  gem 'rubocop', '~> 1.39.0'
  gem 'rubocop-rails', '~> 2.17'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.15'
  gem 'shoulda-matchers', '~> 5.2.0'
  gem 'turbo_test'
  gem 'erb_lint', require: false
end

group :ci, :test do
  gem 'action_mailer_matchers', '~> 1.2'
  gem 'database_cleaner-active_record'
  gem 'stripe-ruby-mock', '~> 2.4.1', require: 'stripe_mock', git: 'https://github.com/commitchange/stripe-ruby-mock.git', branch: '2.4.1'
  gem 'test-unit', '~> 3.5'
  gem 'timecop', '~> 0.9.6'
  gem 'webmock', '~> 3.18'
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
  gem 'rack-timeout', '~> 0.6.3'
end

gem 'bess', path: 'gems/bess'

gem 'houdini_full_contact', path: 'gems/houdini_full_contact'

gem "react_on_rails", "12.6.0"

gem 'kaminari'

gem 'http_accept_language'

gem "js-routes"