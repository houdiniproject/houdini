# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.data @map_data do |md|
  json.extract! md, :name, :latitude, :longitude, :id,  :email, :phone
end
