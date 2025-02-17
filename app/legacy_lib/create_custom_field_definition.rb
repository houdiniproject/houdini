# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreateCustomFieldDefinition
  def self.create(nonprofit, params)
    nonprofit.custom_field_definitions.create(params)
  end
end
