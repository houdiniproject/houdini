class EmailDraft < ActiveRecord::Base

	attr_accessible \
		:nonprofit, :nonprofit_id,
		:name,
		:deleted,
		:value,
		:created_at

	belongs_to :nonprofit

	scope :not_deleted, ->{where(deleted: [nil,false])}

end

