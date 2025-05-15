class DisputeTransaction < ApplicationRecord
  belongs_to :dispute
  belongs_to :payment
  attr_accessible :gross_amount, :disbursed, :payment, :fee_total,
    :stripe_transaction_id, :date

  has_one :nonprofit, through: :dispute
  has_one :supporter, through: :dispute
  has_many :manual_balance_adjustments, as: :entity

  def gross_amount=(gross_amount)
    write_attribute(:gross_amount, gross_amount)
    calculate_net
  end

  def fee_total=(fee_total)
    write_attribute(:fee_total, fee_total)
    calculate_net
  end

  def from_donation?
    !!dispute&.get_original_payment&.donation
  end

  private

  def calculate_net
    self.net_amount = gross_amount + fee_total
  end
end
