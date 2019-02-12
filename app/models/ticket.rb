# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Ticket < ActiveRecord::Base
  
  attr_accessible :note, :event_discount, :event_discount_id

  belongs_to :event_discount
	belongs_to :supporter
	belongs_to :profile
	belongs_to :ticket_level
	belongs_to :event
	belongs_to :charge
	belongs_to :card
	belongs_to :payment
	belongs_to :source_token
	has_one :address, as: :transactionable, class_name: 'TransactionAddress'
	has_one :nonprofit, through: :event
	has_many :activities, as: :attachment, dependent: :destroy

end
