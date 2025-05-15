# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
child @events => :data do
  collection @events, object_root: false
  attributes :name, :date, :url, :id
end
