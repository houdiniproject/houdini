# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.data @tag_definitions do |tag_definition|
  json.call(tag_definition, :id, :name, :created_at)
end
