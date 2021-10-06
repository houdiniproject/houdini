# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @custom_field_definitions do |cfm|
  json.extract! cfm, :name, :id, :created_at
end
