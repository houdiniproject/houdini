# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Transaction < ApplicationRecord
	include Model::Houidable
	setup_houid :trx
	
	belongs_to :supporter
	has_many :transaction_assignments

	has_many :ticket_purchases, through: :transaction_assignments, source: :assignable, source_type: 'TicketPurchase'

	validates :supporter, presence: true


	def to_builder(*expand)
		Jbuilder.new do |json|
			json.(self, :id)
			json.object 'transaction'
			json.supporter supporter.id
			json.nonprofit supporter.nonprofit.id
			json.amount do 
        json.value_in_cents amount || 0
        json.currency supporter.nonprofit.currency
      end
		end
	end
end
