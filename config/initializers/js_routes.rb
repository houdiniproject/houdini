# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
JsRoutes.setup do |c|
  # Setup your JS module system:
  # ESM, CJS, AMD, UMD or nil
  c.module_type = "CJS"
  c.camel_case = true
end
