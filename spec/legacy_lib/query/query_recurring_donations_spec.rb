# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

# Note that the recurring donation used in these tests is created on 2020-01-01 and the first charge is created on that date

describe QueryRecurringDonations do
  around do |example|
    Timecop.freeze(2020, 4, 5) do
      example.run
    end
  end

  describe ".calculate_monthly_donation_total" do
    let(:nonprofit) { Qx.insert_into(:nonprofits).values(name: SecureRandom.uuid).ts.returning("*").execute.first }
    let(:rec_dons) do
      Qx.insert_into("recurring_donations").values([
        {active: true, amount: 4000, interval: 1, time_unit: "month"},
        {active: true, amount: 1000, interval: 2, time_unit: "week"},
        {active: false, amount: 10_000, interval: 1, time_unit: "month"}
      ]).common_values(nonprofit_id: nonprofit["id"]).ts.returning("*").execute
    end

    it "adds up the total for all active recurring donations" do
      rec_dons
      sum = QueryRecurringDonations.calculate_monthly_donation_total(nonprofit["id"])
      expect(sum).to eq(rec_dons[0]["amount"] + rec_dons[1]["amount"])
    end
  end

  describe ".is_due?" do
    let(:nonprofit) { force_create(:nm_justice) }
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
    let(:donation) do
      force_create(:donation, amount: 1000, supporter: supporter, recurring: true, nonprofit: nonprofit)
    end

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
      rd = create_recdon(paydate: 10)
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(1.month.from_now.change(day: 10)) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 3 days and it is 3 days later" do
      rd = create_recdon(time_unit: "day", interval: 3)
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(3.days.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 2 weeks and it is 2 weeks later" do
      rd = create_recdon(time_unit: "week", interval: 2)
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(2.weeks.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is due when not monthly and the timespan is 1 year and it is 1 year later" do
      rd = create_recdon(time_unit: "year", interval: 1)
      Qx.insert_into(:charges).values(donation_id: rd["donation_id"], amount: 1000, supporter_id: supporter["id"], nonprofit_id: nonprofit["id"], status: "pending").ts.ex
      Timecop.freeze(1.year.from_now) do
        expect(QueryRecurringDonations.is_due?(rd["id"])).to be true
      end
    end

    it "is not due when not monthly and it is not a timespan later" do
      rd = create_recdon(time_unit: "day", interval: 3)
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
      rd = create_recdon(paydate: 2)
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
  end

  describe ".for_export_enumerable" do
    before do
      @nonprofit = force_create(:nm_justice, name: "npo1")
      @supporters = [force_create(:supporter, name: "supporter-0", nonprofit: @nonprofit),
        force_create(:supporter, name: "supporter-1", nonprofit: @nonprofit)]

      @recurring_donations = [force_create(:recurring_donation, amount: 1000, active: false, n_failures: 0, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_1"),
        force_create(:recurring_donation, amount: 2000, active: true, n_failures: 3, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_2"),
        force_create(:recurring_donation, amount: 3000, active: true, n_failures: 0, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_3"),
        force_create(:recurring_donation, amount: 400, active: false, n_failures: 3, nonprofit: @nonprofit, donation: force_create(:donation), edit_token: "edit_token_4")]
      @root_url = "https://localhost:8080"
    end

    let(:headers) { MockHelpers.recurring_donation_export_headers }

    it "finishes recurring donation export" do
      rows = QueryRecurringDonations.for_export_enumerable(@nonprofit.id, {}).to_a

      expect(rows.length).to eq(5)
      expect(rows[0]).to eq(headers)
    end

    it "retrieves active" do
      rows = QueryRecurringDonations.for_export_enumerable(@nonprofit.id, active_and_not_failed: true, root_url: "https://localhost:8080/").to_a

      expect(rows.length).to eq(2)

      expect(rows[0]).to eq(headers)
      expect(rows[1][1]).to eq("$30.00")
      expect(rows[1][-1]).to eq(MockHelpers.generate_expected_rd_management_url(@root_url, @recurring_donations[2]))
    end

    it "retrieves cancelled" do
      rows = QueryRecurringDonations.for_export_enumerable(@nonprofit.id, active_and_not_failed: false, root_url: "https://localhost:8080/").to_a

      expect(rows.length).to eq(2)
      expect(rows[0]).to eq(headers)
      expect(rows[1][1]).to eq("$10.00")
      expect(rows[1][-1]).to eq("")
    end

    it "retrieves failed" do
      rows = QueryRecurringDonations.for_export_enumerable(@nonprofit.id, failed: true, root_url: "https://localhost:8080/").to_a

      expect(rows.length).to eq(3)
      expect(rows[0]).to eq(headers)
      expect(rows[1][1]).to eq("$20.00")
      expect(rows[2][1]).to eq("$4.00")
      expect(rows[1][-1]).to eq(MockHelpers.generate_expected_rd_management_url(@root_url, @recurring_donations[1]))
      expect(rows[2][-1]).to eq("")
    end

    it "retrieves not-failed" do
      rows = QueryRecurringDonations.for_export_enumerable(@nonprofit.id, failed: false, root_url: "https://localhost:8080/").to_a

      expect(rows.length).to eq(3)
      expect(rows[0]).to eq(headers)
      expect(rows[1][1]).to eq("$10.00")
      expect(rows[2][1]).to eq("$30.00")

      expect(rows[1][-1]).to eq("")
      expect(rows[2][-1]).to eq(MockHelpers.generate_expected_rd_management_url(@root_url, @recurring_donations[2]))
    end
  end
end # describe
