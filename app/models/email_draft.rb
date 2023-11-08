# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailDraft < ApplicationRecord

	attr_accessible \
		:nonprofit, :nonprofit_id,
		:name,
		:deleted,
		:value,
		:created_at

	belongs_to :nonprofit

	scope :not_deleted, ->{where(deleted: [nil,false])}

end

