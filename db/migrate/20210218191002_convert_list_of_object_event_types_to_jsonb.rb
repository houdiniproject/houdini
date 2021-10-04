# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ConvertListOfObjectEventTypesToJsonb < ActiveRecord::Migration[6.1]
  def change
    remove_column :object_event_hook_configs, :object_event_types, :text
    add_column :object_event_hook_configs, :object_event_types, :jsonb, null: false, default: []
  end
end
