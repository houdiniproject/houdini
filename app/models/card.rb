# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Card < ApplicationRecord
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

  scope :amex_only,	-> { where("cards.name ILIKE ? OR cards.name ILIKE ?", "American Express%", "amex%") }
  scope :not_amex, -> { where("cards.name NOT ILIKE ? AND cards.name NOT ILIKE ?", "American Express%", "amex%") }

  scope :held_by_nonprofits, -> { where("cards.holder_type = ? ", "Nonprofit") }
  scope :held_by_supporters, -> { where("cards.holder_type = ? ", "Supporter") }

  attr_accessor :failure_message

  belongs_to :holder, polymorphic: true
  has_many :charges
  has_many :donations
  has_many :recurring_donations, through: :donations
  has_many :tickets
  has_one :source_token, as: :tokenizable

  # an helpful method for getting the supporter when it's the holder
  def supporter
    if holder_type == "Supporter"
      holder
    end
  end

  # an helpful method for getting the supporter's nonprofit
  # when the supporter is the holder
  def supporter_nonprofit
    supporter&.nonprofit
  end

  def amex?
    !!(name =~ /American Express.*/i)
  end

  def not_amex?
    !amex?
  end

  def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def stripe_card
    @stripe_card ||= stripe_customer.sources.retrieve(stripe_card_id)
  end

  concerning :Maintenance do
    included do
      # is this originally from balanced?
      scope :legacy_balanced, -> { where("cards.stripe_customer_id ILIKE ?", "%balanced%") }
      # Is this originally not from balanced
      scope :not_legacy_balanced, -> { where("cards.stripe_customer_id NOT ILIKE ?", "%balanced%") }
      # is this card unused
      scope :unused, -> { references(:charges, :donations, :tickets).includes(:charges, :donations, :tickets).where("donations.id IS NULL AND charges.id IS NULL AND tickets.id IS NULL") }

      # these are stripe_card_ids which are on multiple cards
      scope :nonunique_stripe_card_ids, -> { where.not(stripe_card_id: nil).group("stripe_card_id").having("COUNT(id) > 1").select("stripe_card_id, COUNT(id)") }

      # cards we feel we can detach from Stripe due to nonuse
      # this are cards which:
      # * have a unique stripe card id (not on another Card object)
      # * owned by a Supporter
      # * never been on associated with a charge, donation or ticket
      # * was created more than a month ago
      # * not originally from the Balanced service used before Stripe
      def self.detachable_because_of_nonuse
        # we want cards which are:
        possible_cards = not_legacy_balanced.unused.held_by_supporters.where("cards.created_at < ?", 1.month.ago).where.not(cards: {stripe_card_id: nil})

        nonunique_ids = nonunique_stripe_card_ids.map { |i| i.stripe_card_id }
        possible_cards.select { |i| !nonunique_ids.include? i.stripe_card_id }
      end
    end
  end
end
