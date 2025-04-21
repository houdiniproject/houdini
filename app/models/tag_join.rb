# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TagJoin < ApplicationRecord
  # :supporter, :supporter_id,
  # :tag_definition, :tag_definition_id

  validates :tag_definition, presence: true

  belongs_to :tag_definition
  belongs_to :supporter

  def name
    tag_definition.name
  end

  def self.create_with_name(nonprofit, h)
    tm = nonprofit.tag_definitions.find_by_name(h["name"])
    tm = nonprofit.tag_definitions.create(name: h["name"]) if tm.nil?
    create tag_definition: tm, supporter_id: h["supporter_id"]
  end
end
