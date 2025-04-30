# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object false

child @custom_field_masters => :data do
  collection @custom_field_masters, object_root: false
  attributes :name, :id, :created_at
end
