# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object false

child @map_data => :data do
  collection @map_data, object_root: false
  attributes :name, :latitude, :longitude, :id
end
