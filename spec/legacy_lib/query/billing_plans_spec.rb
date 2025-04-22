# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe BillingPlans do
  let(:percentage) { 0.34 }
  let(:billing_plan) do
    force_create(:billing_plan, percentage_fee: percentage)
  end

  let(:nonprofit) do
    force_create(:nm_justice)
  end

  describe ".get_percentage_fee" do
    describe "param validation" do
      it "rejects non-integers" do
        expect { BillingPlans.get_percentage_fee("not an integer") }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, [{key: :nonprofit_id, name: :is_integer}])
        end)
      end

      it "rejects invalid nonprofits" do
        expect { BillingPlans.get_percentage_fee(55_555) }.to(raise_error do |error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, [{key: :nonprofit_id}])
        end)
      end
    end

    it "returns 0 when no billing_subscription" do
      result = BillingPlans.get_percentage_fee(nonprofit.id)
      expect(result).to eq 0
    end

    # TODO: not sure this is what we actually want?
    it "returns 0 when billing plan is invalid" do
      force_create(:billing_subscription, billing_plan: nil, nonprofit: nonprofit)

      result = BillingPlans.get_percentage_fee(nonprofit.id)
      expect(result).to eq(0)
    end

    it "returns percentage when billing subscription exists" do
      force_create(:billing_subscription, billing_plan: billing_plan, nonprofit: nonprofit)

      result = BillingPlans.get_percentage_fee(nonprofit.id)
      expect(result).to eq 0.34
    end
  end
end
