# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ManualBalanceAdjustment < ApplicationRecord
  belongs_to :entity, polymorphic: true, required: true
  belongs_to :payment, required: true
  has_one :supporter, through: :payment
  has_one :nonprofit, through: :payment

  validates_presence_of :gross_amount, :fee_total, :net_amount

  before_validation :add_payment, on: :create

  scope :not_disbursed, -> { where(disbursed: [nil, false]) }
  scope :disbursed, -> { where(disbursed: [true]) }

  def gross_amount=(gross_amount)
    write_attribute(:gross_amount, gross_amount)
    calculate_net
  end

  def fee_total=(fee_total)
    write_attribute(:fee_total, fee_total)
    calculate_net
  end

  private

  def calculate_net
    self.net_amount = (gross_amount || 0) + (fee_total || 0)
  end

  def add_payment
    unless payment
      if entity
        build_payment(supporter: entity.supporter, nonprofit: entity.nonprofit, kind: "ManualAdjustment",
          gross_amount: gross_amount || 0,
          fee_total: fee_total || 0,
          net_amount: net_amount,
          date: Time.current)
      end
    end
  end
end
