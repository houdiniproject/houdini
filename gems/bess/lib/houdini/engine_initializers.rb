# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# loads all of the engine initializer modules for Houdini
module Houdini::EngineInitializers
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload
  initializer_path = File.expand_path(File.join(File.dirname(__FILE__), "engine_initializers"))
  initializers = Dir.glob("#{initializer_path}/*").to_a
  initializers.each do |file|
    autoload File.basename(file, ".rb").camelize.to_sym
    include "Houdini::EngineInitializers::#{File.basename(file, ".rb").camelize}".constantize
  end
end
