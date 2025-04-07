# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemoveLongAndLat < ActiveRecord::Migration[6.1]
  def change
    [:users, :events, :nonprofits, :supporters].each do |i|
      remove_column i, :longitude, "double precision"
      remove_column i, :latitude, "double precision"
    end
  end
end
