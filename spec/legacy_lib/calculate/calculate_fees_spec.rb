# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require_relative "../../../app/legacy_lib/calculate_fees"

describe CalculateFees do
  describe ".for_single_amount" do
    it "returns 2.2% + platform fee + 30 cents for an online donation" do
      expect(CalculateFees.for_single_amount(10_000, 0.018)).to eq(430)
    end

    it "returns 2.2% + + 30 cents for an online donation with no platform fee" do
      expect(CalculateFees.for_single_amount(10_000)).to eq(250)
    end

    it "returns 2.2% + platform fee + 30 cents for an online donation with higher platform fee" do
      expect(CalculateFees.for_single_amount(10_000, 0.038)).to eq(630)
    end

    it "raises an error with a negative amount" do
      expect { CalculateFees.for_single_amount(-10, 0.01) }.to raise_error(ParamValidation::ValidationError)
    end

    it "raises an error with a negative fee" do
      expect { CalculateFees.for_single_amount(1000, -0.01) }.to raise_error(ParamValidation::ValidationError)
    end
  end
end
