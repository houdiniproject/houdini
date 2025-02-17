require "houdini/full_contact/engine"

module Houdini::FullContact
  extend ActiveSupport::Autoload

  autoload :InsertInfos

  mattr_accessor :api_key, :max_attempts
end
