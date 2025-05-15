# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe CalculateSuggestedAmounts do
  describe ".calculate" do
    it "param validation" do
      expect { CalculateSuggestedAmounts.calculate(nil) }.to(raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error, [{key: :amount, name: :required}, {key: :amount, name: :is_a}, {key: :amount, name: :min}, {key: :amount, name: :max}])
      })

      expect { CalculateSuggestedAmounts.calculate("fffff") }.to(raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error, [{key: :amount, name: :is_a}, {key: :amount, name: :min}, {key: :amount, name: :max}])
      })
    end

    it "1 gives you 2-4" do
      result = CalculateSuggestedAmounts.calculate(100)
      expect(result).to eq([200, 300, 400])
    end

    it "1.25 gives you 1, 2-4" do
      result = CalculateSuggestedAmounts.calculate(125)
      expect(result).to eq([100, 200, 300, 400])
    end

    it "2 gives you 1, 3-5" do
      result = CalculateSuggestedAmounts.calculate(200)
      expect(result).to eq([100, 300, 400, 500])
    end

    it "9 gives you 8, 10, 15,20" do
      result = CalculateSuggestedAmounts.calculate(900)
      expect(result).to eq([800, 1000, 1500, 2000])
    end

    it "9.5 gives you 9, 10, 15,20" do
      result = CalculateSuggestedAmounts.calculate(950)
      expect(result).to eq([900, 1000, 1500, 2000])
    end

    it "10 gives you 9, 15, 20, 25" do
      result = CalculateSuggestedAmounts.calculate(1000)
      expect(result).to eq([900, 1500, 2000, 2500])
    end

    it "11 gives you 10, 15, 20, 25" do
      result = CalculateSuggestedAmounts.calculate(1100)
      expect(result).to eq([1000, 1500, 2000, 2500])
    end

    it "35 gives you 30, 40, 45, 50" do
      result = CalculateSuggestedAmounts.calculate(3500)
      expect(result).to eq([3000, 4000, 4500, 5000])
    end

    it "40 gives you 35, 45, 50, 75" do
      result = CalculateSuggestedAmounts.calculate(4000)
      expect(result).to eq([3500, 4500, 5000, 7500])
    end

    it "43 gives you 40, 45, 50, 75" do
      result = CalculateSuggestedAmounts.calculate(4300)
      expect(result).to eq([4000, 4500, 5000, 7500])
    end

    it "47 gives you 45, 50, 75, 100" do
      result = CalculateSuggestedAmounts.calculate(4700)
      expect(result).to eq([4500, 5000, 7500, 10000])
    end

    it "47 gives you 45, 50, 75, 100" do
      result = CalculateSuggestedAmounts.calculate(4700)
      expect(result).to eq([4500, 5000, 7500, 10000])
    end

    it "50 gives you 45, 75, 100, 125" do
      result = CalculateSuggestedAmounts.calculate(5000)
      expect(result).to eq([4500, 7500, 10000, 12500])
    end

    it "65 gives you 50, 75, 100, 125" do
      result = CalculateSuggestedAmounts.calculate(6500)
      expect(result).to eq([5000, 7500, 10000, 12500])
    end

    it "75 gives you 50, 100, 125, 150" do
      result = CalculateSuggestedAmounts.calculate(7500)
      expect(result).to eq([5000, 10000, 12500, 15000])
    end

    it "999925 gives you 999900, 999950, 999975" do
      result = CalculateSuggestedAmounts.calculate(99992500)
      expect(result).to eq([99990000, 99995000, 99997500])
    end

    it "999950 gives you 999925, 999975" do
      result = CalculateSuggestedAmounts.calculate(99995000)
      expect(result).to eq([99992500, 99997500])
    end
  end
end
