class InlineJob::ModernObjectDonationStripeChargeJob < InlineJob
  queue_as :default

  def perform(donation:, legacy_payment:)
    supporter = Supporter.find(donation.supporter_id)
    trx = supporter.transactions.build(amount: legacy_payment.gross_amount, created: legacy_payment["date"])

    don = trx.donations.build(amount: legacy_payment.gross_amount, legacy_donation: donation)

    stripe_transaction_charge = SubtransactionPayment.new(
      legacy_payment: legacy_payment,
      paymentable: StripeTransactionCharge.new,
      created: legacy_payment.date
    )
    stripe_t = trx.build_subtransaction(
      subtransactable: StripeTransaction.new(amount: legacy_payment.gross_amount),
      subtransaction_payments: [
        stripe_transaction_charge
      ]
    )
    trx.save!
    don.save!
    stripe_t.save!
    stripe_t.subtransaction_payments.each(&:publish_created)
    # stripe_t.publish_created
    don.publish_created
    trx.publish_created
  end
end
