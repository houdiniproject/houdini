# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

# Note that the recurring donation used in these tests is created on 2020-01-01 and the first charge is created on that date

describe QueryRecurringDonations do
  around(:each) { |example|
    Timecop.freeze(2020, 4, 5) do
      example.run
    end
  }

  describe ".monthly_total" do
    let(:nonprofit) { Qx.insert_into(:nonprofits).values(name: SecureRandom.uuid).ts.returning("*").execute.first }
    let(:rec_dons) do
      Qx.insert_into("recurring_donations").values([
        {active: true, amount: 4000, interval: 1, time_unit: "month"},
        {active: true, amount: 1000, interval: 2, time_unit: "week"},
        {active: false, amount: 10000, interval: 1, time_unit: "month"}
      ]).common_values({nonprofit_id: nonprofit["id"]}).ts.returning("*").execute
    end

    it "adds up the total for all active recurring donations" do
      rec_dons
      sum = QueryRecurringDonations.monthly_total(nonprofit["id"])
      expect(sum).to eq(rec_dons[0]["amount"] + rec_dons[1]["amount"])
    end
  end

  describe ".is_due?" do
    let(:nonprofit) { force_create(:nonprofit) }
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
    let(:donation) {
      force_create(:donation, amount: 1000, supporter: supporter, recurring: true, nonprofit: nonprofit)
    }

    let(:defaults) { {amount: 1000, interval: 1, time_unit: "month", nonprofit: nonprofit, supporter: supporter, active: true, donation: donation} }

    def create_recdon(params)
      force_create(:recurring_donation, defaults.merge(params))
    end

    it "when inactive, is not due" do
      rd = create_recdon(active: false)
      expect(QueryRecurringDonations.is_due?(rd.id)).to eq(false)
    end

    it "when it hits max n_failures, is not due" do
      rd = create_recdon(n_failures: 3)
      expect(QueryRecurringDonations.is_due?(rd.id)).to eq(false)
    end

    it "is due when it has no charges" do
      rd = create_recdon({})
      expect(QueryRecurringDonations.is_due?(rd.id)).to eq(true)
    end

    it "is not due when it has a charge this month" do
      rd = create_recdon({})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
    end

    it "is due when it has charges && when monthly && not paid this month && not paid last month" do
      rd = create_recdon({})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(2.months.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when monthly && no paydate && last charge was last month && last charge created at day <= today" do
      rd = create_recdon({})
      Timecop.freeze(Time.parse("2020-01-01")) do
        Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      end
      Timecop.freeze(Time.parse("2020-02-01")) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when monthly && paydate present && last charge was last month && paydate <= today" do
      rd = create_recdon({paydate: 10})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(1.month.from_now.change(day: 10)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 3 days and it is 3 days later" do
      rd = create_recdon({time_unit: "day", interval: 3})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(3.days.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 2 weeks and it is 2 weeks later" do
      rd = create_recdon({time_unit: "week", interval: 2})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(2.weeks.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 1 year and it is 1 year later" do
      rd = create_recdon({time_unit: "year", interval: 1})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(1.year.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is not due when not monthly and it is not a timespan later" do
      rd = create_recdon({time_unit: "day", interval: 3})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(2.days.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end

    it "is not due when monthly and has been paid this month" do
      rd = create_recdon({})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
    end

    it "is not due when monthly and no paydate and today is < last charge created_at day" do
      rd = create_recdon({})
      Timecop.freeze(Time.parse("2020-01-02")) do
        Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      end
      Timecop.freeze(Time.parse("2020-02-01")) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end

    it "is not due when monthly an a paydate is present and today < paydate" do
      rd = create_recdon({paydate: 2})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(1.month.from_now.change(day: 1)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end

    it "is due when monthly and there are only failed charges this month" do
      rd = create_recdon({})
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "failed").ts.ex
      Timecop.freeze(1.month.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when monthly AND there is a recurring_donation_hold but no end_date" do
      rd = create_recdon({})
      rd.create_recurring_donation_hold!
      Timecop.freeze(1.month.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when monthly AND there is a recurring_donation_hold but end_date has passed" do
      rd = create_recdon({})
      rd.create_recurring_donation_hold end_date: 1.week.from_now
      Timecop.freeze(1.month.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when monthly AND there is a recurring_donation_hold and end_date has passed but were still in the current month" do
      rd = create_recdon({})
      rd.create_recurring_donation_hold end_date: 1.month.from_now + 1.day
      Timecop.freeze(1.month.from_now + 2.days) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is not due when monthly AND there is a recurring_donation_hold and end_date hasnt passed" do
      rd = create_recdon({})
      rd.create_recurring_donation_hold end_date: 1.week.from_now
      expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
    end

    it "is not due when monthly AND the recurring_donation_hold has just ended" do
      donation = force_create(:donation)
      payment = force_create(:payment, donation: donation)
      force_create(:charge, payment: payment, status: "disbursed", donation: donation, created_at: Time.new(2021, 1, 15))
      rd = create_recdon({donation: donation})
      Timecop.freeze(Time.new(2021, 5, 2)) do
        rd.create_recurring_donation_hold end_date: Time.new(2021, 5, 1)
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end

    it "is not due when monthly AND the recurring_donation_hold has just ended AND paydate specifically is in the future" do
      donation = force_create(:donation)
      payment = force_create(:payment, donation: donation)
      force_create(:charge, payment: payment, status: "disbursed", donation: donation, created_at: Time.new(2021, 1, 15))
      rd = create_recdon({donation: donation, paydate: 22})
      rd.create_recurring_donation_hold end_date: Time.new(2021, 5, 1)
      Timecop.freeze(Time.new(2021, 5, 1)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end

      Timecop.freeze(Time.new(2021, 5, 2)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end

    it "is due when monthly AND the recurring_donation_hold has just ended AND has paydate and is time to charge!" do
      donation = force_create(:donation)
      payment = force_create(:payment, donation: donation)
      force_create(:charge, payment: payment, status: "disbursed", donation: donation, created_at: Time.new(2021, 1, 15))
      rd = create_recdon({donation: donation, paydate: 22})
      rd.create_recurring_donation_hold end_date: Time.new(2021, 5, 1)
      Timecop.freeze(Time.new(2021, 5, 22)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is not due when monthly AND the recurring_donation_hold has just ended AND has paydate and is almost time to charge" do
      donation = force_create(:donation)
      payment = force_create(:payment, donation: donation)
      force_create(:charge, payment: payment, status: "disbursed", donation: donation, created_at: Time.new(2021, 1, 15))
      rd = create_recdon({donation: donation, paydate: 22})
      rd.create_recurring_donation_hold end_date: Time.new(2021, 5, 1)
      Timecop.freeze(Time.new(2021, 5, 21)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be false
      end
    end
  end

  describe ".for_export_enumerable" do
    around(:each) do |ex|
      StripeMockHelper.mock do
        ex.run
      end
    end

    let(:failed) {
      [
        force_create(:recurring_donation, amount: 2000, active: true, n_failures: 3, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_2"),
        force_create(:recurring_donation, amount: 400, active: false, n_failures: 3, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_4")
      ]
    }

    let(:cancelled) {
      [force_create(:recurring_donation, amount: 1000, active: false, n_failures: 0, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_1")]
    }

    let(:active) {
      [
        force_create(:recurring_donation, amount: 3000, active: true, n_failures: 0, nonprofit: @nonprofit, donation: force_create(:donation, card: force_create(:card, stripe_customer_id: "stripe_cus_id")), edit_token: "edit_token_3"),
        force_create(:recurring_donation, amount: 200, active: true, n_failures: 0, end_date: Time.current + 1.day, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_6")
      ]
    }

    let(:fulfilled) {
      [
        force_create(:recurring_donation, amount: 100, active: true, n_failures: 0, end_date: Time.current - 1.day, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_5")
      ]
    }

    before :each do
      @nonprofit = force_create(:nonprofit, name: "npo1")
      @supporters = [force_create(:supporter, name: "supporter-0", nonprofit: @nonprofit),
        force_create(:supporter, name: "supporter-1", nonprofit: @nonprofit)]

      @recurring_donations = [].concat(failed).concat(cancelled).concat(active).concat(fulfilled)
      @root_url = "https://localhost:8080"
    end

    let(:headers) { MockHelpers.recurring_donation_export_headers }

    it "finishes recurring donation export" do
      rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {}).to_a), headers: true)

      expect(rows.length).to eq(6)
      expect(rows[0].headers).to eq(headers)
    end

    it "retrieves active" do
      rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {active_and_not_failed: true, root_url: "https://localhost:8080/"}).to_a), headers: true)

      expect(rows.length).to eq(2)
      expect(rows[0].headers).to eq(headers)
      expect(rows[0]["Amount"]).to eq("$30.00")
      expect(rows[0]["Status"]).to eq "active"
      expect(rows[1]["Amount"]).to eq("$2.00")
      expect(rows[0]["Donation Management Url"]).to eq(MockHelpers.generate_expected_rd_management_url(@root_url, active[0]))
      expect(rows[0]["Status"]).to eq "active"
    end

    it "retrieves fulfilled" do
      rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {fulfilled: true, root_url: "https://localhost:8080/"}).to_a), headers: true)

      expect(rows.length).to eq(1)
      expect(rows[0].headers).to eq(headers)
      expect(rows[0]["Amount"]).to eq("$1.00")
      expect(rows[0]["Status"]).to eq "fulfilled"
      expect(rows[0]["Donation Management Url"]).to eq("")
    end

    it "retrieves cancelled" do
      rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {active_and_not_failed: false, root_url: "https://localhost:8080/"}).to_a), headers: true)

      expect(rows.length).to eq(1)
      expect(rows[0].headers).to eq(headers)
      expect(rows[0]["Amount"]).to eq("$10.00")
      expect(rows[0]["Donation Management Url"]).to eq("")
      expect(rows[0]["Status"]).to eq "cancelled"
    end

    context "failed charges" do
      it "retrieves failed" do
        rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {failed: true, root_url: "https://localhost:8080/"}).to_a), headers: true)

        expect(rows.length).to eq(1)
        expect(rows[0].headers).to eq(headers)
        expect(rows[0]["Amount"]).to eq("$20.00")
        expect(rows[0]["Donation Management Url"]).to eq(MockHelpers.generate_expected_rd_management_url(@root_url, failed[0]))
      end

      context "when the query includes last failed charge param" do
        before do
        end
        let(:headers_with_last_failed_charge) do
          MockHelpers.recurring_donation_export_headers_with_last_failed_charge
        end

        let(:rows) do
          CSV.parse(
            Format::Csv.from_array(
              QueryRecurringDonations.for_export_enumerable(
                @nonprofit.id,
                {
                  failed: true,
                  include_last_failed_charge: true,
                  root_url: "https://localhost:8080/"
                }
              ).to_a
            ),
            headers: true
          )
        end

        it "contains Last Failed Charge" do
          expect(rows[0].headers).to eq(headers_with_last_failed_charge)
        end
      end
    end

    it "retrieves not-failed" do
      rows = CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {failed: false, root_url: "https://localhost:8080/"}).to_a), headers: true)

      expect(rows.length).to eq(4)
      expect(rows[0].headers).to eq(headers)
      expect(rows[0]["Amount"]).to eq("$10.00")
      expect(rows[1]["Amount"]).to eq("$30.00")

      expect(rows[3]["Donation Management Url"]).to eq("")
    end

    it "gets the stripe_customer_id when requested" do
      expect(csv.select { |i| i["Stripe Customer Id"] == "stripe_cus_id" }).to be_any
    end

    let(:csv) do
      CSV.parse(Format::Csv.from_array(QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {active_and_not_failed: true, include_stripe_customer_id: true, root_url: "https://localhost:8080/"}).to_a), headers: true)
    end
  end
end # describe
