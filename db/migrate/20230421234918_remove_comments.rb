# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemoveComments < ActiveRecord::Migration[6.1]
  def change
    drop_table :comments
  end
end
