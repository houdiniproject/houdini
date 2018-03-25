child @events => :data do
	collection @events, object_root: false
	attributes :name, :date, :url, :id
end
