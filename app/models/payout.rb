# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Payouts record a credit of the total pending balance on a nonprofit's account
# to their bank account or debit card
#
# These are tied to Stripe transfers

# Unless you're sure, DO NOT CREATE THESE USING STANDARD ACTIVERECORD METHODS. Use `InsertPayout.with_stripe` instead.
class Payout < ApplicationRecord
  setup_houid :pyout, :houid

  attr_accessible \
    :scheduled, # bool (whether this was made automatically at the beginning of the month)
    :count, # int (number of donations for this payout)
    :ach_fee, # int (in cents, the total fee for the payout itself)
    :gross_amount, # int (in cents, total amount before fees)
    :fee_total, # int (in cents, total amount of fees)
    :net_amount, # int (in cents, total amount after fees for this payout)
    :email, # str (cache of user email who issued this)
    :user_ip, # str (ip address of the user who made this payout)
    :status, # str ('pending', 'paid', 'canceled', or 'failed')
    :failure_message, # str
    :bank_name, # str: cache of the nonprofit's bank name
    :stripe_transfer_id, # str
    :nonprofit_id, :nonprofit

  belongs_to :nonprofit
  has_one :bank_account, through: :nonprofit
  has_many :payment_payouts
  has_many :payments, through: :payment_payouts
  has_many :object_events, as: :event_entity

  validates :stripe_transfer_id, presence: true, uniqueness: true
  validates :nonprofit, presence: true
  validates :bank_account, presence: true
  validates :email, presence: true
  validates :net_amount, presence: true, numericality: {greater_than: 0}
  validate :nonprofit_must_be_vetted, on: :create
  validate :nonprofit_must_have_identity_verified, on: :create
  validate :bank_account_must_be_confirmed, on: :create

  delegate :currency, :stripe_account_id, to: :nonprofit

  as_money :net_amount

  scope :pending, -> { where(status: "pending") }
  scope :paid, -> { where(status: ["paid", "succeeded"]) }

  # Older transfers use the Stripe::Transfer object, newer use Stripe::Payout object
  def transfer_type
    if stripe_transfer_id.start_with?("tr_", "test_tr_")
      :transfer
    elsif stripe_transfer_id.start_with?("po_", "test_po_")
      :payout
    end
  end

  # Older transfers use the Stripe::Transfer object, newer use Stripe::Payout object
  def sdk_class
    if transfer_type == :payout
      Stripe::Payout
    else
      Stripe::Transfer
    end
  end

  # Retrieves the associated Stripe::Payout and Stripe::Transfer object via Stripe API
  def sdk_object
    sdk_class.retrieve(stripe_transfer_id, {
      stripe_account: stripe_account_id
    })
  end

  def bank_account_must_be_confirmed
    if bank_account && bank_account.pending_verification
      errors.add(:bank_account, "must be confirmed via email")
    end
  end

  def nonprofit_must_have_identity_verified
    errors.add(:nonprofit, "must be verified") unless nonprofit && nonprofit&.stripe_account&.payouts_enabled
  end

  def nonprofit_must_be_vetted
    errors.add(:nonprofit, "must be vetted") unless nonprofit && nonprofit.vetted
  end

  def publish_created
    object_events.create(event_type: "payout.created")
  end
end
