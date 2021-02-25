# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Card < ActiveRecord::Base

	attr_accessible \
		:cardholders_name, # str (name associated with this card)
		:email, # str (cache the email associated with this card)
		:name, # str (readable card name, eg. Visa *1234)
		:failure_message, # accessor for temporarily storing the stripe decline message
		:status, # str
		:stripe_card_token, # str
		:stripe_card_id, # str
		:stripe_customer_id, # str
		:holder, :holder_id, :holder_type, # polymorphic cardholder association
		:inactive # a card is inactive. This is currently only meaningful for nonprofit cards

	scope :amex_only, 	where('cards.name ILIKE ? OR cards.name ILIKE ?', 'American Express%', 'amex%')
	scope :not_amex, where('cards.name NOT ILIKE ? AND cards.name NOT ILIKE ?', 'American Express%', 'amex%')

	attr_accessor :failure_message


	belongs_to :holder, polymorphic: true
	has_many :charges
	has_many :donations
	has_many :tickets

	def amex?
		!!(name =~ /American Express.*/i)
	end

	def not_amex?
		!amex?
	end

end
