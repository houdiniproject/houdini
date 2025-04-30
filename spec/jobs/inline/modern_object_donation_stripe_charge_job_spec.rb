# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe InlineJob::ModernObjectDonationStripeChargeJob, type: :job do
  let(:nonprofit) { force_create(:nonprofit, statement: "swhtowht", name: "atata") }
  let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }

  let(:stripe_cust_id) { "cus_123455" }
  let(:stripe_card_id) { "card_1234555" }
  let(:card) {
    force_create(:card, holder: supporter, stripe_customer_id: stripe_cust_id, stripe_card_id: stripe_card_id)
  }
  let(:donation) { force_create(:donation, supporter: supporter, amount: 300, card: card, nonprofit: nonprofit) }
  let(:recurring_donation) { force_create(:recurring_donation, donation: donation, start_date: Time.now - 1.day, active: true, nonprofit: nonprofit, n_failures: 0, interval: 1, time_unit: "month") }
  let(:misc_recurring_donation_info__covered) {
    force_create(:misc_recurring_donation_info, recurring_donation: recurring_donation, fee_covered: true)
  }

  let(:recent_charge) { force_create(:charge, donation: donation, card: card, amount: 300, status: "paid", created_at: Time.now - 1.day, payment: recent_payment) }

  let(:recent_payment) { force_create(:payment, gross_amount: 300, date: Time.now - 1.day, supporter: supporter) }
  let(:performed_job) {
    InlineJob::ModernObjectDonationStripeChargeJob.perform_now(legacy_payment: recent_charge.payment, donation: donation)
  }

  it {
    expect { performed_job }.to change { Transaction.count }.by(1)
  }

  it {
    expect { performed_job }.to change { SubtransactionPayment.count }.by(1)
  }

  it {
    expect { performed_job }.to change { StripeTransactionCharge.count }.by(1)
  }

  it {
    expect { performed_job }.to change { ModernDonation.count }.by(1)
  }

  it {
    expect { performed_job }.to change { ModernDonation.last&.legacy_donation }.to(donation)
  }
  it {
    expect { performed_job }.to change { nonprofit.associated_object_events.event_types("stripe_transaction_charge.created").count }.by(1)
  }
end
