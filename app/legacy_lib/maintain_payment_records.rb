# frozen_string_literal: true

module MaintainPaymentRecords
  # For records which have no associated charge, refund, nonprofit, supporter, donation or a gross_amount
  # The record is basically useless
  def self.find_records_which_are_really_bad
    Payment.includes(:charges).includes(:refund).where("payments.nonprofit_id IS NULL AND payments.supporter_id IS NULL AND payments.donation_id IS NULL AND payments.gross_amount IS NULL AND charges.id IS NULL AND refunds.id IS NULL")
  end

  def self.set_payment_supporter_and_nonprofit_though_charge_refund(i)
    p = Payment.includes(refund: :charge).find(i)
    p.supporter_id = p.refund.charge.supporter_id
    p.nonprofit_id = p.refund.charge.nonprofit_id
    p.refund.disbursed = true
    p.refund.save!
    p.save!
  end

  def self.delete_payment_and_offsite_payment_record(id)
    p = Payment.includes(:offsite_payment).find(id)
    p.offsite_payment&.destroy
    p.destroy
  end
end
