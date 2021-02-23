# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class RemoveOldUnusedSupporterAttributes < ActiveRecord::Migration[6.1]
  def change
    remove_column :supporters, :fields, :text
    remove_column :supporters, :notes, :text
  end
end
