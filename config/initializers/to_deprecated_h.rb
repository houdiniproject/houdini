ActiveSupport.on_load(:action_controller_base) do
  require "to_deprecated_h"
end
