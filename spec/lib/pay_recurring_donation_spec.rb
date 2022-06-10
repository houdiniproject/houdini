# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe PayRecurringDonation  do

  before(:all) do
    #@data = PsqlFixtures.init
   # @result = @data['recurring_donation']
  end

  describe '.with_donation' do
    include_context :shared_donation_charge_context
    
    around (:each)  do |example|
      Timecop.freeze( 2020, 5,4) do 
        StripeMockHelper.mock do 
          example.run
        end
      end
    end

    let(:nonprofit) { force_create(:nonprofit, statement:'swhtowht', name: 'atata')}
    let(:supporter) {force_create(:supporter, nonprofit:nonprofit)}

    let(:stripe_cust_id) { customer = Stripe::Customer.create();
    customer.id}
    let(:card) {
      card = Stripe::Customer.create_source(stripe_cust_id, {source: StripeMockHelper.generate_card_token(brand: 'Visa', country: 'US')})
      force_create(:card, holder: supporter, stripe_customer_id: stripe_cust_id, stripe_card_id: card.id)
    }
    let(:donation) {force_create(:donation, supporter: supporter, amount: 300, card: card, nonprofit: nonprofit)}
    let(:recurring_donation) { force_create(:recurring_donation, donation: donation, start_date: Time.now - 1.day, active:true, nonprofit: nonprofit, n_failures: 0, interval: 1, time_unit: 'month')}
    let(:misc_recurring_donation_info__covered) {
      force_create(:misc_recurring_donation_info, recurring_donation: recurring_donation, fee_covered: true)
    }

    let(:recent_charge) {force_create(:charge, donation:donation, card:card, amount: 300, status:'paid', created_at: Time.now - 1.day)} 

    let(:successful_charge_argument) { 
      {
        customer:stripe_cust_id,
        amount:300,
        currency:'usd',
        statement_descriptor_suffix:'Donation swhtowht',
        metadata: {
          kind: 'RecurringDonation',
          nonprofit_id: nonprofit.id
        },
        application_fee:37
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

    it 'covered_result doesnt return false' do
      expect(covered_result).to_not eq false
    end

    it 'uncovered_result doesnt return false' do
      expect(uncovered_result).to_not eq false
    end

    it 'marks the payment as covering fees' do 
      res = covered_result
      expect(donation.payments.first.misc_payment_info.fee_covered).to eq true
    end

    it 'marks the payment as not covering fees' do 
      res = uncovered_result
      expect(donation.payments.first.misc_payment_info&.fee_covered).to be_falsey
    end

    it 'returns false if not due' do 
      res = result_with_recent_charge
      expect(res).to eq false
    end

    it 'runs even if not due if we force' do 
      res = result_with_recent_charge_but_forced
      expect(res).to_not eq false
    end
	end

  describe '.pay_all_due_with_stripe', :pending => true do

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
