object false

child @refunds => :data do
	collection @refunds, object_root: false
	attributes :id, :amount, :created_at, :reason, :comment

end
