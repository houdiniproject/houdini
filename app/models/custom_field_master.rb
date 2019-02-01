# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CustomFieldMaster < ApplicationRecord

	attr_accessible \
		:nonprofit, :nonprofit_id,
		:name,
		:deleted,
		:created_at

	validates :name, presence: true
	validate :no_dupes, on: :create

	belongs_to :nonprofit
	has_many :custom_field_joins, dependent: :destroy

	scope :not_deleted, ->{where(deleted: [nil,false])}

	def no_dupes
		return self if nonprofit.nil?
		errors.add(:base, "Duplicate custom field") if nonprofit.custom_field_masters.not_deleted.where(name: name).any?
	end

end

