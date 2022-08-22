# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemoveSecondAndThirdImagesFromNonprofit < ActiveRecord::Migration
  def change
    remove_column :nonprofits, :second_image
    remove_column :nonprofits, :third_image
  end
end
