module CreateCustomFieldMaster

	def self.create(nonprofit, params)
		custom_field_master = nonprofit.custom_field_masters.create(params)
		return custom_field_master
	end
end
