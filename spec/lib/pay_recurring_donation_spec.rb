# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe PayRecurringDonation do
  before(:all) do
    # @data = PsqlFixtures.init
    # @result = @data['recurring_donation']
  end

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  describe ".with_stripe" do
    include_context :shared_donation_charge_context

    around(:each) do |example|
      Timecop.freeze(2020, 5, 4) do
        StripeMockHelper.mock do
          example.run
        end
      end
    end

    let(:nonprofit) { force_create(:nonprofit, statement: "swhtowht", name: "atata") }
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }

    let(:stripe_cust_id) {
      customer = Stripe::Customer.create
      customer.id
    }
    let(:card) {
      card = Stripe::Customer.create_source(stripe_cust_id, {source: StripeMockHelper.generate_card_token(brand: "Visa", country: "US")})
      force_create(:card, holder: supporter, stripe_customer_id: stripe_cust_id, stripe_card_id: card.id)
    }
    let(:donation) { force_create(:donation, supporter: supporter, amount: 300, card: card, nonprofit: nonprofit) }
    let(:recurring_donation) { force_create(:recurring_donation, donation: donation, start_date: Time.now - 1.day, active: true, nonprofit: nonprofit, n_failures: 0, interval: 1, time_unit: "month") }
    let(:misc_recurring_donation_info__covered) {
      force_create(:misc_recurring_donation_info, recurring_donation: recurring_donation, fee_covered: true)
    }

    let(:recent_charge) { force_create(:charge, donation: donation, card: card, amount: 300, status: "paid", created_at: Time.now - 1.day) }

    let(:successful_charge_argument) {
      {
        customer: stripe_cust_id,
        amount: 300,
        currency: "usd",
        statement_descriptor_suffix: "Donation swhtowht",
        metadata: {
          kind: "RecurringDonation",
          nonprofit_id: nonprofit.id
        },
        application_fee: 37
      }
    }

    let(:covered_result) {
      misc_recurring_donation_info__covered
      PayRecurringDonation.with_stripe(recurring_donation.id)
    }

    let(:uncovered_result) {
      PayRecurringDonation.with_stripe(recurring_donation.id)
    }

    let(:result_with_recent_charge) {
      recent_charge
      uncovered_result
    }

    let(:result_with_recent_charge_but_forced) {
      recent_charge
      PayRecurringDonation.with_stripe(recurring_donation.id, true)
    }

    let!(:admin_user) do
      create(:user, id: 540)
    end

    context "result when fees covered" do
      it {
        expect(covered_result).to_not eq false
      }

      it {
        expect { covered_result }.to have_enqueued_job(InlineJob::ModernObjectDonationStripeChargeJob)
          .with(donation: donation, legacy_payment: an_instance_of(Payment).and(
            have_attributes(
              gross_amount: 300,
              supporter: supporter,
              donation: donation
            )
          ))
      }

      it {
        covered_result
        expect(donation.payments.first.misc_payment_info.fee_covered).to eq true
      }
    end

    context "result when fees not covered" do
      it {
        expect(uncovered_result).to_not eq false
      }

      it {
        expect { uncovered_result }.to have_enqueued_job(InlineJob::ModernObjectDonationStripeChargeJob)
          .with(donation: donation, legacy_payment: an_instance_of(Payment).and(
            have_attributes(
              gross_amount: 300,
              supporter: supporter,
              donation: donation
            )
          ))
      }

      it {
        uncovered_result
        expect(donation.payments.first.misc_payment_info&.fee_covered).to be_falsey
      }
    end

    context "result when not due" do
      it {
        expect(result_with_recent_charge).to eq false
      }

      it {
        expect { result_with_recent_charge }.to_not have_enqueued_job(InlineJob::ModernObjectDonationStripeChargeJob)
      }
    end

    context "result when not due but forced" do
      it {
        expect(result_with_recent_charge_but_forced).to_not eq false
      }

      it {
        expect { result_with_recent_charge_but_forced }.to have_enqueued_job(InlineJob::ModernObjectDonationStripeChargeJob)
          .with(donation: donation, legacy_payment: an_instance_of(Payment).and(
            have_attributes(
              gross_amount: 300,
              supporter: supporter,
              donation: donation
            )
          ))
      }
    end

    context "n_failures = 0 and failed again" do
      before(:each) do
        recurring_donation.n_failures = 0
        recurring_donation.save!
        StripeMockHelper.prepare_card_error(:card_declined)
      end

      it "sets n_failures to 1" do
        PayRecurringDonation.with_stripe(recurring_donation.id, true)

        recurring_donation.reload

        expect(recurring_donation.n_failures).to eq 1
      end

      it "sends an email to the donor but not nonprofit" do
        delayed_mailer = double(DonationMailer)
        expect(DonationMailer).to receive(:delay).once.and_return(delayed_mailer)

        expect(delayed_mailer).to receive(:donor_failed_recurring_donation).with(recurring_donation.donation_id)

        expect(delayed_mailer).to_not receive(:nonprofit_failed_recurring_donation)

        PayRecurringDonation.with_stripe(recurring_donation.id, true)
      end
    end

    context "n_failures = 2 and failed again" do
      before(:each) do
        recurring_donation.n_failures = 2
        recurring_donation.save!
        StripeMockHelper.prepare_card_error(:card_declined)
      end

      it "sets n_failures to 3" do
        PayRecurringDonation.with_stripe(recurring_donation.id, true)

        recurring_donation.reload

        expect(recurring_donation.n_failures).to eq 3
      end

      it "sends an email to the nonprofit" do
        delayed_mailer = double(DonationMailer)
        allow(DonationMailer).to receive(:delay).and_return(delayed_mailer)

        expect(delayed_mailer).to receive(:donor_failed_recurring_donation).with(recurring_donation.donation_id)

        expect(delayed_mailer).to receive(:nonprofit_failed_recurring_donation).with(recurring_donation.donation_id)

        PayRecurringDonation.with_stripe(recurring_donation.id, true)
      end
    end
  end

  describe ".pay_all_due_with_stripe", pending: true do
    # it 'queues a job to pay each due recurring donation' do
    #   Timecop.freeze(Time.parse("2020-02-01").utc) do
    #     VCR.use_cassette('PayRecurringDonation/pay_all_due_with_stripe') do
    #       PayRecurringDonation.pay_all_due_with_stripe
    #     end
    #   end
    #   jerbz = Psql.execute("SELECT * FROM delayed_jobs WHERE queue='rec-don-payments'")
    #   handlers = jerbz.map{|j| YAML.load(j['handler'])}
    #   expect(handlers.count).to eq(handlers.select{|h| h.method_name == :with_stripe}.count)
    #   expect(handlers.count).to eq(handlers.select{|h| h.object == PayRecurringDonation}.count)
    #   expect(handlers.map{|h| h.args}.flatten).to include(@result['recurring_donation']['id'])
    #   Psql.execute("DELETE FROM delayed_jobs WHERE queue='rec-don-payments'")
    # end
  end
end
