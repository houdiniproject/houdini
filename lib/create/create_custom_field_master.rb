# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module CreateCustomFieldMaster
  def self.create(nonprofit, params)
    custom_field_master = nonprofit.custom_field_masters.create(params)
    custom_field_master
  end
end
