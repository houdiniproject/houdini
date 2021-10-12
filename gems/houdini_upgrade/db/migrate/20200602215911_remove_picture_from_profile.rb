# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemovePictureFromProfile < ActiveRecord::Migration[6.0]
  def change
    remove_column :profiles, :picture
  end
end
