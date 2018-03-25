object false

child @custom_field_joins => :data do
	collection @custom_field_joins, object_root: false
	attributes :name, :created_at, :id, :value
end
