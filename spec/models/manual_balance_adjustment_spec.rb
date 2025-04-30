# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe ManualBalanceAdjustment, type: :model do
  it { is_expected.to belong_to(:entity).required(true) }
  it { is_expected.to belong_to(:payment).required(true) }
  it { is_expected.to have_one(:supporter).through(:payment) }
  it { is_expected.to have_one(:nonprofit).through(:payment) }
  it { is_expected.to validate_presence_of(:gross_amount) }
  it { is_expected.to validate_presence_of(:fee_total) }
  it { is_expected.to validate_presence_of(:net_amount) }

  describe "included in QueryPayments.ids_for_payout calculations" do
    it "is not included when disbursed" do
      Timecop.freeze(Time.new(2020, 2, 1) - 1.day) do
        manual_balance = create(:manual_balance_adjustment, :with_entity_and_payment, disbursed: true)
        Timecop.freeze(Time.new(2020, 2, 1)) do
          expect(QueryPayments.ids_for_payout(manual_balance.nonprofit.id)).to_not include manual_balance.payment.id
        end
      end
    end

    it "is included when not disbursed" do
      Timecop.freeze(Time.new(2020, 2, 1) - 1.day) do
        manual_balance = create(:manual_balance_adjustment, :with_entity_and_payment)
        Timecop.freeze(Time.new(2020, 2, 1)) do
          expect(QueryPayments.ids_for_payout(manual_balance.nonprofit.id)).to include manual_balance.payment.id
        end
      end
    end
  end

  it "included in QueryPayments.get_payout_totals calculations" do
    Timecop.freeze(Time.new(2020, 2, 1) - 1.day) do
      manual_balance = create(:manual_balance_adjustment, :with_entity_and_payment)
      Timecop.freeze(Time.new(2020, 2, 1)) do
        expected_attributes = {"count" => 1, "gross_amount" => 0, "fee_total" => -100, "net_amount" => -100}

        expect(QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(manual_balance.nonprofit.id))).to eq expected_attributes
      end
    end
  end

  describe "included in QueryPayments.nonprofit_balances calculations" do
    it "is not included when disbursed" do
      Timecop.freeze(Time.new(2020, 2, 1) - 1.day) do
        manual_balance = create(:manual_balance_adjustment, :with_entity_and_payment, disbursed: true)
        Timecop.freeze(Time.new(2020, 2, 1)) do
          expect(QueryPayments.nonprofit_balances(manual_balance.nonprofit.id)).to eq({
            "available" => {"gross" => 0, "net" => 0},
            "pending" => {"gross" => 0, "net" => 0}
          })
        end
      end
    end

    it "is included when not disbursed" do
      Timecop.freeze(Time.new(2020, 2, 1) - 1.day) do
        manual_balance = create(:manual_balance_adjustment, :with_entity_and_payment)
        Timecop.freeze(Time.new(2020, 2, 1)) do
          expect(QueryPayments.nonprofit_balances(manual_balance.nonprofit.id)).to eq({
            "available" => {"gross" => 0, "net" => -100},
            "pending" => {"gross" => 0, "net" => 0}
          })
        end
      end
    end
  end
end
