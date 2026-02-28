# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Format::Currency do
  symbol = Houdini.intl.currencies[0]

  describe ".dollars_to_cents" do
    context "with dollar sign" do
      it "converts to a cents value as an integer" do
        expect(Format::Currency.dollars_to_cents("#{symbol}11.11")).to eq(1111)
      end
    end

    context "without dollar sign" do
      it "converts to a cents value as an integer" do
        expect(Format::Currency.dollars_to_cents("11.00")).to eq(1100)
      end
    end

    context "with large amount" do
      it "converts to a cents value as an integer" do
        expect(Format::Currency.dollars_to_cents("#{symbol}111111111111.11")).to eq(11_111_111_111_111)
      end
    end
  end

  describe ".cents_to_dollars" do
    context "hundreth-precision (eg $1.11)" do
      it "converts to dollars with hundredth precision" do
        expect(Format::Currency.cents_to_dollars(111)).to eq("1.11")
      end
    end

    context "tenth-precision (eg. $1.10)" do
      it "converts to dollars with a trailing zero" do
        expect(Format::Currency.cents_to_dollars(110)).to eq("1.10")
      end
    end

    context "whole value (eg. $1)" do
      it "converts to dollars without decimals" do
        expect(Format::Currency.cents_to_dollars(100)).to eq("1")
      end
    end
  end
end
