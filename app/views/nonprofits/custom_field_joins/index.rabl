# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
object false

child @custom_field_joins => :data do
  collection @custom_field_joins, object_root: false
  attributes :name, :created_at, :id, :value
end
