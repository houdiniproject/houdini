# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec'
require 'rspec/rails'
require 'factory_girl'
require 'warden'
require 'devise'
require 'capybara/dsl'
require 'factories'
require 'nulldb/rails'
Warden.test_mode!

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.include Capybara::DSL, type: :request
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, :type => :controller
end