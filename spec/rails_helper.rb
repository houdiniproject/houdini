# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start 'rails' do
  add_group 'Forms', 'app/forms'
  add_group 'Gems', 'gems'
  add_group 'Libraries' do |src|
    src.filename.include?('lib') && !src.filename.include?('app/legacy_lib') && !src.filename.include?('gems')
  end
  add_group 'Legacy Lib', 'app/legacy_lib'
  add_group 'Uploaders', 'app/uploaders'
  add_group 'Validators', 'app/validators'
end

ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "spec_helper"
require "rspec/rails"
require "devise"
# Add additional requires below this line. Rails is not loaded until this point!
require "support/factory_bot"
require "support/date_time"
require "support/stripe_mock_helper"
require "timecop"
require "delayed_job"
require "support/contexts"
require "action_mailer_matchers"
Delayed::Worker.delay_jobs = false
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include RSpec::Rails::RequestExampleGroup, type: :request, file_path: /spec\/api/

  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include ActionMailerMatchers

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, reset_ids: true)
    Rails.cache.clear
  end

  config.before(:each, type: :routing) do
    # this makes sure that our routes have a default host which is what they need for testing
    allow(Rails.application.routes).to receive(:default_url_options).and_return(ApplicationMailer.default_url_options)
  end

  config.after(:each) do
    StripeMockHelper.stop
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
      Rails.cache.clear
    end
  end

  FactoryBot::SyntaxRunner.class_eval do
    include RSpec::Matchers
    include RSpec::Mocks::ExampleMethods
  end
end
