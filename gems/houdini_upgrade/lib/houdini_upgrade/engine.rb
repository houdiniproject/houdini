# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module HoudiniUpgrade
  class Engine < ::Rails::Engine
    isolate_namespace HoudiniUpgrade
  end
end
