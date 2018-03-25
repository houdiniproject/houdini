object false

child @campaigns => :data do
	collection @campaigns, object_root: false
	attributes :name, :total_raised, :goal_amount, :url, :id
end

