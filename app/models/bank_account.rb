# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class BankAccount < ApplicationRecord
  # :name, # str (readable bank name identifier, eg. "Wells Fargo *1234")
  # :confirmation_token, # str (randomly generated private token for email confirmation)
  # :account_number, # str (last digits only)
  # :bank_name, # str
  # :pending_verification, # bool (whether this bank account is still awaiting email confirmation)
  # :status, # str
  # :email, # str (contact email associated with the user who created this bank account)
  # :deleted, # bool (soft delete flag)
  # :stripe_bank_account_token, # str
  # :stripe_bank_account_id, # str
  # :nonprofit_id, :nonprofit
  validates :stripe_bank_account_token, presence: true, uniqueness: true
  validates :stripe_bank_account_id, presence: true, uniqueness: true
  validates :nonprofit, presence: true
  validates :email, presence: true, format: {with: Email::Regex}
  validate  :nonprofit_must_be_vetted, on: :create
  validate  :nonprofit_has_stripe_account

  has_many :payouts
  belongs_to :nonprofit

  def nonprofit_must_be_vetted
    errors.add(:nonprofit, 'must be vetted') unless nonprofit&.vetted
  end

  def nonprofit_has_stripe_account
    errors.add(:nonprofit, 'must have a Stripe account id') if !nonprofit || nonprofit.stripe_account_id.blank?
  end

  # Manually cause an instance to become invalid
  def invalidate!
    @not_valid = true
  end
end
