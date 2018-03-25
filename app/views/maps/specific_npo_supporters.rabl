object false

child @map_data => :data do
	collection @map_data, object_root: false
	attributes :name, :latitude, :longitude, :id, :email, :phone, :address, :city, :state_code, :total_raised
end
