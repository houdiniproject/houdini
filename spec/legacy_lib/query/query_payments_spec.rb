# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "support/payments_for_a_payout"

describe QueryPayments do
  before do
    @nonprofit = force_create(:nm_justice, name: "npo1", id: 515152)
    @supporters = [force_create(:supporter, name: "supporter-0", nonprofit: @nonprofit),
      force_create(:supporter, name: "supporter-1", nonprofit: @nonprofit)]

    @payments = [force_create(:payment, gross_amount: 1000, fee_total: 99, net_amount: 901, supporter: @supporters[0], nonprofit: @nonprofit),
      force_create(:payment, gross_amount: 2000, fee_total: 22, net_amount: 1978, supporter: @supporters[1], nonprofit: @nonprofit)]
    @bank_account = force_create(:bank_account, name: "bank1", nonprofit: @nonprofit)
  end

  describe ".ids_for_payout" do
    before do
      Timecop.freeze(2020, 5, 5)
    end

    after do
      Timecop.return
    end

    describe "no date provided" do
      include_context "payments for a payout" do
        let(:np) { @nonprofit }
        let(:date_for_marking) { Time.now }
      end

      it "np is invalid" do
        expect(QueryPayments.ids_for_payout(686_826_812_658_102_751_098_754)).to eq []
      end

      it "works without a date provided" do
        all_payments

        result = QueryPayments.ids_for_payout(np.id)

        payments_for_payout = Set.new
        @expect_marked[:charges].each do |c|
          c.reload
          payments_for_payout.add(c.payment.id)
        end

        @expect_marked[:disputes].each do |d|
          d.reload
          payments_for_payout.add(d.payment.id)
        end

        @expect_marked[:refunds].each do |r|
          r.reload
          payments_for_payout.add(r.payment.id)
        end

        expect(result).to match_array(payments_for_payout)
      end
    end

    describe "with date provided" do
      include_context "payments for a payout" do
        let(:np) { @nonprofit }
        let(:date_for_marking) { Time.now - 1.day }
      end

      it "np is invalid" do
        expect(QueryPayments.ids_for_payout(686_826_812_658_102_751_098_754)).to eq []
      end

      it "works with a date provided" do
        all_payments

        result = QueryPayments.ids_for_payout(np.id, date: Time.now - 1.day)

        payments_for_payout = Set.new
        @expect_marked[:charges].each do |c|
          c.reload
          payments_for_payout.add(c.payment.id)
        end

        @expect_marked[:disputes].each do |d|
          d.reload
          payments_for_payout.add(d.payment.id)
        end

        @expect_marked[:refunds].each do |r|
          r.reload
          payments_for_payout.add(r.payment.id)
        end

        expect(result).to match_array(payments_for_payout)
      end
    end
  end

  describe ".get_payout_total" do
    include_context "payments for a payout" do
      let(:np) { @nonprofit }
      let(:date_for_marking) { Time.now }
    end
    it "gives empty payout result if no payments provided" do
      result = QueryPayments.get_payout_totals([])

      expected = {"gross_amount" => 0, "fee_total" => 0, "net_amount" => 0}
      expect(result).to eq expected
    end

    it "gives correct payout info" do
      all_payments
      result = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(np.id))
      expected = {gross_amount: 5500, fee_total: -1200, net_amount: 4300, count: 8}.with_indifferent_access

      expect(result.with_indifferent_access).to eq expected
    end
  end

  describe ".for_payout" do
    before do
      gross = @payments.map { |h| h["gross_amount"] }.sum
      fees = @payments.map { |h| h["fee_total"] }.sum
      net = @payments.map { |h| h["net_amount"] }.sum
      @payout = force_create(:payout, gross_amount: gross, fee_total: fees, net_amount: net, nonprofit: @nonprofit)
      @payment_payouts = @payments.map { |p| force_create(:payment_payout, payment: p, payout: @payout) }

      @result = QueryPayments.for_payout(@nonprofit["id"], @payout["id"])
    end

    it "sets the correct headers" do
      expect(@result.first).to eq(%w[date gross_total fee_total net_total bank_name status])
    end

    it "sets the correct payout data" do
      expect(@result[1].count).to eq(6) # TODO
    end

    it "sets the payment headers", pending: true do
      expect(@result[3]).to eq(["Date", "Gross Amount", "Fee Total", "Net Amount", "Type", "Payment ID", "Last Name", "First Name", "Full Name", "Organization", "Email", "Phone", "Address", "City", "State", "Postal Code", "Country", "Anonymous?", "Designation", "Honorarium/Memorium", "Comment", "Campaign", "Campaign Gift Level", "Event"])
    end

    it "sets the correct payment data", pending: true do
      expect(@result[4].count).to eq 24
    end
  end

  describe ".for_export_enumerable" do
    it "finishes two payment export" do
      rows = QueryPayments.for_export_enumerable(@nonprofit.id, {}).to_a

      headers = MockHelpers.payment_export_headers

      expect(rows.length).to eq(3)
      expect(rows[0]).to eq(headers)
    end
  end

  describe ".full_search" do
    include_context :shared_rd_donation_value_context
    before do
      nonprofit.stripe_account_id = Stripe::Account.create["id"]
      nonprofit.save!
      card.stripe_customer_id = "some other id"
      cust = Stripe::Customer.create
      card.stripe_customer_id = cust["id"]
      card.save!
      expect(Stripe::Charge).to receive(:create).exactly(3).times.and_wrap_original { |m, *args|
        a = m.call(*args)
        @stripe_charge_id = a["id"]
        a
      }
    end

    let(:charge_amount_small) { 200 }
    let(:charge_amount_medium) { 400 }
    let(:charge_amount_large) { 600 }

    def generate_donation(h)
      token = h[:token]
      date = h[:date]
      amount = h[:amount]

      input = {amount: amount,
               nonprofit_id: nonprofit.id,
               supporter_id: supporter.id,
               token: token,

               date: date,
               dedication: {"type" => "honor", "name" => "a name"},
               designation: "designation"}
      input[:event_id] = h[:event_id] if h[:event_id]

      input[:campaign_id] = h[:campaign_id] if h[:campaign_id]

      InsertDonation.with_stripe(input)
    end

    describe "general donations" do
      let(:donation_result_yesterday) do
        generate_donation(amount: charge_amount_small,

          token: source_tokens[0].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:donation_result_today) do
        generate_donation(amount: charge_amount_medium,

          token: source_tokens[1].token,

          date: Time.now.to_s)
      end

      let(:donation_result_tomorrow) do
        generate_donation(amount: charge_amount_large,

          token: source_tokens[2].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:first_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)
      end

      let(:second_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)
      end

      it "empty filter returns all" do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments.full_search(nonprofit.id, {})

        expect(result[:data].count).to eq 5
      end

      context "considering the nonprofit timezone on the query result" do
        before do
          donation_result_today
          first_refund_of_yesterday
          second_refund_of_yesterday
        end

        it "when the nonprofit does not have a timezone it considers UTC as default" do
          donation_result_tomorrow
          result = QueryPayments.full_search(nonprofit.id, {})
          expect(result[:data].first["date"]).to eq Time.now.to_s
        end

        context "when the nonprofit has a timezone" do
          before do
            nonprofit.update(timezone: "America/New_York")
            allow(QuerySourceToken)
              .to receive(:get_and_increment_source_token)
              .and_return(source_tokens[0])
          end

          it "shows the corresponding time" do
            donation_result_tomorrow
            result = QueryPayments.full_search(nonprofit.id, {})
            expect(result[:data].first["date"]).to eq (Time.now - 4.hours).to_s
          end

          it "finds the payments on dates after the specified dates" do
            donation_result_tomorrow
            result = QueryPayments.full_search(nonprofit.id, {after_date: Time.now - 4.hours})
            expect(result[:data].count).to eq 5
          end

          it "finds the payments on dates before the specified dates" do
            donation_result_tomorrow
            result = QueryPayments.full_search(nonprofit.id, {before_date: Time.now})
            expect(result[:data].count).to eq 5
          end

          it "finds the payments of an specific year" do
            # creating a payment at 1 AM UTC from january 2020
            # should not be included in the 2020 query if we are at America/New_York
            Timecop.freeze(2020, 1, 1, 1, 0, 0, "+00:00")
            generate_donation(
              amount: charge_amount_large,
              token: source_tokens[2].token,
              date: Time.now.to_s
            )
            result_for_2020 = QueryPayments.full_search(nonprofit.id, {year: "2020"})
            result_for_2019 = QueryPayments.full_search(nonprofit.id, {year: "2019"})
            expect(result_for_2019[:data].count).to eq 1
            expect(result_for_2020[:data].count).to eq 4
          end
        end
      end
    end

    describe "event donations" do
      let(:donation_result_yesterday) do
        generate_donation(amount: charge_amount_small,
          event_id: event.id,
          token: source_tokens[0].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:donation_result_today) do
        generate_donation(amount: charge_amount_medium,
          event_id: event.id,
          token: source_tokens[1].token,

          date: Time.now.to_s)
      end

      let(:donation_result_tomorrow) do
        generate_donation(amount: charge_amount_large,

          token: source_tokens[2].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:first_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)
      end

      let(:second_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)
      end

      it "search includes refunds for that event " do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments.full_search(nonprofit.id, event_id: event.id)

        expect(result[:data].count).to eq 4
        expect(result[:data]).to_not satisfy { |i| i.any? { |j| j["id"] == donation_result_tomorrow["payment"]["id"] } }
      end
    end

    describe "campaign donations" do
      let(:donation_result_yesterday) do
        generate_donation(amount: charge_amount_small,
          campaign_id: campaign.id,
          token: source_tokens[0].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:donation_result_today) do
        generate_donation(amount: charge_amount_medium,
          campaign_id: campaign.id,
          token: source_tokens[1].token,

          date: Time.now.to_s)
      end

      let(:donation_result_tomorrow) do
        generate_donation(amount: charge_amount_large,

          token: source_tokens[2].token,
          date: (Time.now - 1.day).to_s)
      end

      let(:first_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 100}.with_indifferent_access)
      end

      let(:second_refund_of_yesterday) do
        charge = donation_result_yesterday["charge"]

        InsertRefunds.with_stripe(charge.attributes, {amount: 50}.with_indifferent_access)
      end

      it "search includes refunds for that campaign " do
        donation_result_yesterday
        donation_result_today
        donation_result_tomorrow
        first_refund_of_yesterday
        second_refund_of_yesterday

        result = QueryPayments.full_search(nonprofit.id, campaign_id: campaign.id)

        expect(result[:data].count).to eq 4
        expect(result[:data]).to_not satisfy { |i| i.any? { |j| j["id"] == donation_result_tomorrow["payment"]["id"] } }
      end
    end
  end
end
