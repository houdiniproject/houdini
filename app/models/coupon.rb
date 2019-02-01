# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Coupon < ApplicationRecord
	attr_accessible \
		:name,
		:victim_np_id,
		:paid, # boolean
		:nonprofit, :nonprofit_id

	scope :unpaid, -> {where(paid: [nil,false])}

	validates_presence_of :name, :nonprofit_id, :victim_np_id
end