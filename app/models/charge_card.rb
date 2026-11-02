# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# The card a Stripe::Charge was paid with, as the #brand and #country that FeeEra needs.
#
# A charge made through the Charges API has its card as its source. A charge made through a PaymentIntent (as Slipflow
# makes them) has no source: its card, Apple Pay and Google Pay included, is in payment_method_details.card, and the
# brand there is a code ("amex") rather than the name a source has ("American Express"), which FeeStructure#brand holds.
class ChargeCard
  # Stripe's card brand codes, mapped to the names a Stripe::Card uses
  # https://docs.stripe.com/api/charges/object#charge_object-payment_method_details-card-brand
  BRAND_NAMES = {
    "amex" => "American Express",
    "diners" => "Diners Club",
    "discover" => "Discover",
    "jcb" => "JCB",
    "mastercard" => "MasterCard",
    "unionpay" => "UnionPay",
    "visa" => "Visa",
    "unknown" => "Unknown"
  }.freeze

  attr_reader :brand, :country

  # @param [Stripe::Charge] charge
  # @return [#brand, #country] the charge's source, or its card from payment_method_details
  # @raise [ArgumentError] if the charge wasn't paid with a card
  def self.of(charge)
    return charge[:source] if charge[:source]

    card = charge[:payment_method_details]&.[](:card)
    raise ArgumentError, "charge #{charge[:id]} has no source and wasn't paid with a card" unless card

    new(brand: BRAND_NAMES.fetch(card[:brand], card[:brand]), country: card[:country])
  end

  def initialize(brand:, country:)
    @brand = brand
    @country = country
  end
end
