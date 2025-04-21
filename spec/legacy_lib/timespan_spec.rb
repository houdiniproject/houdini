# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

require "chronic"
require "timecop"
require_relative "../../app/legacy_lib/timespan"

describe Timespan do
  describe "#later_than_by?" do
    let(:month) { Timespan.create(1, "month") }
    let(:week) { Timespan.create(1, "month") }
    let(:year) { Timespan.create(1, "month") }
    let(:day) { Timespan.create(1, "month") }

    let(:date) { Chronic.parse("2019-01-15") }
    let(:month_later) { Chronic.parse("2019-02-15") }

    context "when second date is later than the first by the timespan," do
      it "returns true" do
        expect(Timespan.later_than_by?(date, month_later, month)).to eq(true)
      end
    end

    context "when the second date is sooner than the first by the timespan," do
      it "returns false" do
        sooner = Chronic.parse("2019-01-25")
        expect(Timespan.later_than_by?(date, sooner, month)).to eq(false)
      end

      context "but when the first date is at the end of a long month and the second date is at the end of a shorter month," do
        let(:jan_31) { Chronic.parse("2019-01-31").to_date }
        let(:feb_28) { Chronic.parse("2019-02-28").to_date }

        it "returns true" do
          expect(Timespan.later_than_by?(jan_31, feb_28, month)).to eq(true)
        end
      end
    end
  end

  describe "#create" do
    it "returns the correct number of seconds constituting a timespan" do
      Timecop.freeze(2018, 3, 25) do
        expect(Timespan.create(1, "month").to_i).to eq(2_629_746)
      end
    end

    it "raises err when given an invalid time unit" do
      expect { Timespan.create(1, "blerg") }.to raise_error(ArgumentError)
    end
  end

  describe "#in_future?" do
    it "returns true when date is in the future" do
      expect(Timespan.in_future?(3.days.from_now)).to be(true)
    end
    it "returns false when date is in the past" do
      expect(Timespan.in_future?(3.days.ago)).to be(false)
    end
  end

  describe "#in_past?" do
    it "returns true when date is in the past" do
      expect(Timespan.in_past?(3.days.ago)).to be(true)
    end
    it "returns false when date is in the future" do
      expect(Timespan.in_past?(3.days.from_now)).to be(false)
    end
  end
end
