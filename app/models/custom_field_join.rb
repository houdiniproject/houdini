# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CustomFieldJoin < ApplicationRecord
  # :supporter,
  # :supporter_id,
  # :custom_field_definition,
  # :custom_field_definition_id,
  # :value

  validates :custom_field_definition, presence: true

  belongs_to :custom_field_definition
  belongs_to :supporter

  def self.create_with_name(nonprofit, h)
    cfm = nonprofit.custom_field_definitions.find_by_name(h["name"])
    cfm = nonprofit.custom_field_definitions.create(name: h["name"]) if cfm.nil?
    create(value: h["value"], custom_field_definition_id: cfm.id, supporter_id: h["supporter_id"])
  end

  def name
    custom_field_definition.name
  end
end
