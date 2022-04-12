# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CreateCustomFieldMaster

	def self.create(nonprofit, params)
		custom_field_master = nonprofit.custom_field_masters.create(params)
		return custom_field_master
	end
end
