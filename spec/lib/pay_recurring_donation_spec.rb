# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'timecop'

describe PayRecurringDonation  do

  before(:all) do
    #@data = PsqlFixtures.init
   # @result = @data['recurring_donation']
  end

	let(:today) {Time.current.to_date}

  describe '.with_donation' do
    let(:stripe_helper) { StripeMock.create_test_helper }
    
    around (:each)  do |example|
      StripeMock.start
        example.run
      StripeMock.stop
    end

    let(:nonprofit) { force_create(:nonprofit, statement:'swhtowht', name: 'atata')}
    let(:supporter) {force_create(:supporter, nonprofit:nonprofit)}
    let(:card) {force_create(:card, holder: supporter, stripe_customer_id: 'cust_id_1')}
    let(:donation) {force_create(:donation, supporter: supporter, amount: 300, card: card, nonprofit: nonprofit)}
    let(:recurring_donation) { force_create(:recurring_donation, donation: donation, start_date: Time.now - 1.day, active:true, nonprofit: nonprofit, n_failures: 0)}
    let(:misc_recurring_donation_info__covered) {
      force_create(:misc_recurring_donation_info, recurring_donation: recurring_donation, fee_covered: true)
    }

    let(:successful_charge_argument) { 
      {
        customer:'cust_id_1',
        amount:300,
        currency:'usd',
        description:'Donation swhtowht',
        statement_descriptor:'Donation swhtowht',
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

  describe '.ULTIMATE_VERIFICATION' do
    it 'returns false' do
      Timecop.freeze(Time.parse('2020-02-01').utc) do
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-02', true, true, false, 'run_dangerously')).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-01', false, true, false, 'run_dangerously')).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-01', true, false, false, 'run_dangerously')).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-01', true, true, true, 'run_dangerously')).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-01', true, true, false, 'rd')).to be_falsey
      end
    end
    it 'returns true' do
      Timecop.freeze(Time.parse('2020-02-01').utc) do
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION('2020-02-01', true, true, false, 'run dangerously')).to be_truthy
      end
    end
  end


end
