# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'
# require '../..app/models/user'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
  end
end
