class Coupon < ActiveRecord::Base
	attr_accessible \
		:name,
		:victim_np_id,
		:paid, # boolean
		:nonprofit, :nonprofit_id

	scope :unpaid, -> {where(paid: [nil,false])}

	validates_presence_of :name, :nonprofit_id, :victim_np_id
end