# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# DisputeCase contains all of the information necessary to build and access the objects used as part of a test case.
class DisputeCase
  include FactoryBot::Syntax::Methods

  def self.all_events
    [:created, :updated, :funds_reinstated, :funds_withdrawn, :won, :lost]
  end

  def legacy_payment
    legacy_donation.payment
  end

  def nonprofit
    supporter.nonprofit
  end

  def supporter
    @supporter ||= create(:supporter_base)
  end

  def stripe_dispute
    event_json = dispute_on_stripe
    @stripe_dispute ||= StripeDispute.create(object: event_json["data"]["object"])
  end

  def legacy_dispute
    @legacy_dispute ||= stripe_dispute.dispute
  end

  def legacy_dispute
    @legacy_dispute ||= stripe_dispute.dispute
  end

  def withdrawal_dispute_transaction
    legacy_dispute.dispute_transactions.order("date").first
  end

  def reinstated_dispute_transaction
    legacy_dispute.dispute_transactions.order("date").second
  end

  def withdrawal_dispute_legacy_payment
    legacy_dispute.dispute_transactions.order("date").first.payment
  end

  def reinstated_dispute_legacy_payment
    legacy_dispute.dispute_transactions.order("date").second.payment
  end

  def transaction_payment_charge
    transaction_to_be_disputed.reload
    transaction_to_be_disputed.ordered_payments.last
  end

  def transaction_payment_withdrawal
    transaction_to_be_disputed.reload
    case transaction_to_be_disputed.ordered_payments.count
    when 2
      transaction_to_be_disputed.ordered_payments.first
    when 3
      transaction_to_be_disputed.ordered_payments.second
    end
  end

  def transaction_payment_reinstated
    transaction_to_be_disputed.reload
    case transaction_to_be_disputed.ordered_payments.count
    when 3
      transaction_to_be_disputed.ordered_payments.first
    end
  end

  def events(types: [])
    nonprofit.associated_object_events.event_types(types).page
  end

  def setup
    dispute_on_stripe
    supporter
    nonprofit
    legacy_donation
    transaction_to_be_disputed
    stripe_dispute
    self
  end
end
