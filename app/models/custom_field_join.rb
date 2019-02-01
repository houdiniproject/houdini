# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CustomFieldJoin < ApplicationRecord

	attr_accessible \
		:supporter, :supporter_id,
		:custom_field_master, :custom_field_master_id,
		:value

	validates :custom_field_master, presence: true

	belongs_to :custom_field_master
  belongs_to :supporter

	def self.create_with_name(nonprofit, h) 
		cfm = nonprofit.custom_field_masters.find_by_name(h['name'])
		if cfm.nil?
			cfm = nonprofit.custom_field_masters.create(name: h['name'])
		end
		self.create({value: h['value'], custom_field_master_id: cfm.id, supporter_id: h['supporter_id']})
	end

	def name; custom_field_master.name; end

end

