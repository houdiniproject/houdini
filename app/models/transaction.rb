# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Transaction < ApplicationRecord
	include Model::Houidable
	include Model::Jbuilder
  include Model::Eventable
	
	setup_houid :trx
	add_builder_expansion :nonprofit, :supporter
	
	belongs_to :supporter
	has_one :nonprofit, through: :supporter

	has_many :transaction_assignments

	has_many :donations, through: :transaction_assignments, source: :assignable, source_type: 'ModernDonation'
	has_many :ticket_purchases, through: :transaction_assignments, source: :assignable, source_type: 'TicketPurchase'
	has_many :campaign_gift_purchases, through: :transaction_assignments, source: :assignable, source_type: 'CampaignGiftPurchase'

	validates :supporter, presence: true


	def to_builder(*expand)
		init_builder(*expand) do |json|
			json.amount do 
        json.cents amount || 0
        json.currency nonprofit.currency
      end
		end
	end

	def publish_created
		Houdini.event_publisher.announce(:transaction_created, 
			to_event('transaction.created', :nonprofit, :supporter).attributes!)
	end
end
