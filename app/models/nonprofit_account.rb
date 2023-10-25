# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class NonprofitAccount < ApplicationRecord

	attr_accessible \
		:stripe_account_id, #str
		:nonprofit, :nonprofit_id #int

	belongs_to :nonprofit

	validates :nonprofit, presence: true
	validates :stripe_account_id, presence: true

end
