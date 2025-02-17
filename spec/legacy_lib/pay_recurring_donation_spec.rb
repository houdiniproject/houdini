# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "timecop"

describe PayRecurringDonation do
  before(:all) do
    # @data = PsqlFixtures.init
    # @result = @data['recurring_donation']
  end

  let(:today) { Time.current.to_date }

  describe ".with_donation", pending: true do
    # describe 'create a valid charge and payment when due' do
    #
    # end
    # it 'creates a new valid charge and payment when due' do
    #   h = Timecop.freeze(Time.parse("2020-02-02").utc) do
    #     VCR.use_cassette('PayRecurringDonation/h1') do
    #       PayRecurringDonation.with_stripe(@result['recurring_donation']['id'])
    #     end
    #   end
    #   expect(h['charge']['stripe_charge_id']).to be_present
    #   expect(h['charge']['card_id']).to eq(@data['donor']['card']['id'])
    #   expect(h['charge']['supporter_id']).to eq(@data['donor']['supporter']['id'])
    #   expect(h['charge']['amount']).to eq(@data['recurring_donation']['recurring_donation']['amount'])
    #   expect(h['charge']['donation_id']).to eq(@result['donation']['id'])
    #   expect(h['charge']['nonprofit_id']).to eq(@data['np']['id'])
    #   expect(h['charge']['status']).to eq('pending')
    #   expect(h['charge']['payment_id']).to eq(h['payment']['id'])
    #   expect(h['payment']['nonprofit_id']).to eq(@data['np']['id'])
    #   expect(h['payment']['date']).to eq(h['payment']['created_at'])
    #   expect(h['payment']['supporter_id']).to eq(@data['donor']['supporter']['id'])
    #   expect(h['payment']['donation_id']).to eq(@result['donation']['id'])
    #   expect(h['payment']['gross_amount']).to eq(@data['recurring_donation']['recurring_donation']['amount'])
    #   expect(h['payment']['kind']).to eq('RecurringDonation')
    #   # Wipe out data for other tests
    #   Psql.execute("DELETE FROM charges  WHERE id = #{h['charge']['id']}")
    #   Psql.execute("DELETE FROM payments WHERE id = #{h['payment']['id']}")
    # end
    #
    # it 'returns a failed charge without a payment when the card is declined, increments n_failures, and is still due' do
    #   Psql.execute("UPDATE donations SET card_id=#{@data['donor']['bad_card']['id']} WHERE id=#{@result['donation']['id']}")
    #   h = Timecop.freeze(Time.parse("2020-02-01").utc) do
    #     VCR.use_cassette('PayRecurringDonation/bad_card') do
    #       PayRecurringDonation.with_stripe(@result['recurring_donation']['id'])
    #     end
    #   end
    #   expect(h['charge']['status']).to eq 'failed'
    #   expect(h['recurring_donation']['n_failures']).to eq 1
    #   Timecop.freeze(Time.parse("2020-02-01").utc) do
    #     expect(QueryRecurringDonations.is_due?(h['recurring_donation']['id'])).to be true
    #   end
    #   Psql.execute("UPDATE donations SET card_id=#{@data['donor']['card']['id']} WHERE id=#{@result['donation']['id']}")
    # end
    #
    # it 'returns false when not due' do
    #   Timecop.freeze(Time.parse("2020-01-01").utc) do
    #     expect(PayRecurringDonation.with_stripe(@result['recurring_donation']['id'])).to be false
    #   end
    # end
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

  describe ".ULTIMATE_VERIFICATION" do
    it "returns false" do
      Timecop.freeze(Time.parse("2020-02-01").utc) do
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-02", true, true, false, "run_dangerously")).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-01", false, true, false, "run_dangerously")).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-01", true, false, false, "run_dangerously")).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-01", true, true, true, "run_dangerously")).to be_falsey
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-01", true, true, false, "rd")).to be_falsey
      end
    end
    it "returns true" do
      Timecop.freeze(Time.parse("2020-02-01").utc) do
        expect(PayRecurringDonation.ULTIMATE_VERIFICATION("2020-02-01", true, true, false, "run dangerously")).to be_truthy
      end
    end
  end
end
