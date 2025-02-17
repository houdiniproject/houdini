# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails/generators/rails/plugin/plugin_generator"
class PluginBuilder < Rails::PluginBuilder
  def license
    template "LICENSE"
    template "AGPL-3.0.txt"
    template "LGPL-3.0.txt"
    template "GPL-3.0.txt"
  end
end

module Rails
  module Generators
    class PluginGenerator
      def source_paths
        [File.expand_path("templates", __dir__)]
      end
    end
  end
end
