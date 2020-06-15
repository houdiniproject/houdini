# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'format/currency'
require 'validation_error'
require 'stripe'
require 'active_support/core_ext'
require 'psql'
require 'qexpr'
require 'calculate/calculate_fees'
require 'param_validation'
require 'insert/insert_activities'

module InsertRefunds
  # Refund a given charge, up to its net amount
  # params: amount, donation obj
  def self.with_stripe(charge, h)
    ParamValidation.new(charge,
                        payment_id: { required: true, is_integer: true },
                        stripe_charge_id: { required: true, format: /^(test_)?ch_.*$/ },
                        amount: { required: true, is_integer: true, min: 1 },
                        id: { required: true, is_integer: true },
                        nonprofit_id: { required: true, is_integer: true },
                        supporter_id: { required: true, is_integer: true })
    ParamValidation.new(h, amount: { required: true, is_integer: true, min: 1 })

    original_payment = Qx.select('*').from('payments').where(id: charge['payment_id']).execute.first
    raise ActiveRecord::RecordNotFound, "Cannot find original payment for refund on charge #{charge['id']}" if original_payment.nil?

    if original_payment['refund_total'].to_i + h['amount'].to_i > original_payment['gross_amount'].to_i
      raise "Refund amount must be less than the net amount of the payment (for charge #{charge['id']})"
    end

    stripe_charge = Stripe::Charge.retrieve(charge['stripe_charge_id'])

    refund_post_data = { 'amount' => h['amount'], 'refund_application_fee' => true, 'reverse_transfer' => true }
    refund_post_data['reason'] = h['reason'] unless h['reason'].blank? # Stripe will error on blank reason field
    stripe_refund = stripe_charge.refunds.create(refund_post_data)
    h['stripe_refund_id'] = stripe_refund.id

    refund_row = Qx.insert_into(:refunds).values(h.merge(charge_id: charge['id'])).timestamps.returning('*').execute.first

    gross = -(h['amount'])
    platform_fee = BillingPlans.get_percentage_fee(charge['nonprofit_id'])
    fees = (h['amount'] * -original_payment['fee_total'] / original_payment['gross_amount']).ceil
    net = gross + fees
    # Create a corresponding negative payment record
    payment_row = Qx.insert_into(:payments).values(
      gross_amount: gross,
      fee_total: fees,
      net_amount: net,
      kind: 'Refund',
      towards: original_payment['towards'],
      date: refund_row['created_at'],
      nonprofit_id: charge['nonprofit_id'],
      supporter_id: charge['supporter_id']
    )
                    .timestamps
                    .returning('*')
                    .execute.first

    InsertActivities.for_refunds([payment_row['id']])

    # Update the refund to have the above payment_id
    refund_row = Qx.update(:refunds).set(payment_id: payment_row['id']).ts.where(id: refund_row['id']).returning('*').execute.first
    # Update original payment to increment its refund_total for any future refund attempts
    Qx.update(:payments).set("refund_total=refund_total + #{h['amount'].to_i}").ts.where(id: original_payment['id']).execute
    # Send the refund receipts in a delayed job
    Houdini.event_publisher.announce(:create_refund, Refund.find(refund_row['id']))
    { 'payment' => payment_row, 'refund' => refund_row }
  end
end
