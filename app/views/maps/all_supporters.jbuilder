# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.data @map_data do |md|
  json.extract! md, :name, :latitude, :longitude, :id,  :email, :phone
end
