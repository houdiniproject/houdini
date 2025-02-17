# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

require_relative "../../app/legacy_lib/numeric"

describe Numeric do
  describe "#floor_for_delta" do
    it "rejects non integers" do
      expect { 2.floor_for_delta("test") }.to raise_error(ArgumentError)
      expect { 2.floor_for_delta(2.3) }.to raise_error(ArgumentError)
    end

    it "rejects negative integers" do
      expect { 2.floor_for_delta(-1) }.to raise_error(ArgumentError)
    end

    it "handles on -25" do
      expect(-25.floor_for_delta(25)).to eq(-25)
    end

    it "handles on -24.5" do
      expect(-24.5.floor_for_delta(25)).to eq(-25)
    end

    it "handles on -1" do
      expect(-1.floor_for_delta(25)).to eq(-25)
    end

    it "handles on 0" do
      expect(0.floor_for_delta(25)).to eq 0
    end

    it "handles on .5" do
      expect(0.5.floor_for_delta(25)).to eq 0
    end

    it "handles on 1" do
      expect(1.floor_for_delta(25)).to eq 0
    end

    it "handles on 25" do
      expect(25.floor_for_delta(25)).to eq 25
    end

    it "handles on 25.5" do
      expect(25.5.floor_for_delta(25)).to eq 25
    end
  end

  describe "#ceil_for_delta" do
    it "rejects non integers" do
      expect { 2.ceil_for_delta("test") }.to raise_error(ArgumentError)
      expect { 2.ceil_for_delta(2.3) }.to raise_error(ArgumentError)
    end

    it "rejects negative integers" do
      expect { 2.ceil_for_delta(-1) }.to raise_error(ArgumentError)
    end

    it "handles on -25.5" do
      expect(-25.5.ceil_for_delta(25)).to eq(-25)
    end

    it "handles on -25" do
      expect(-25.ceil_for_delta(25)).to eq(-25)
    end

    it "handles on -24.5" do
      expect(-24.5.ceil_for_delta(25)).to eq 0
    end

    it "handles on -1" do
      expect(-1.ceil_for_delta(25)).to eq 0
    end

    it "handles on 0" do
      expect(0.ceil_for_delta(25)).to eq 0
    end

    it "handles on .5" do
      expect(0.5.ceil_for_delta(25)).to eq 25
    end

    it "handles on 1" do
      expect(1.ceil_for_delta(25)).to eq 25
    end

    it "handles on 25" do
      expect(25.ceil_for_delta(25)).to eq 25
    end

    it "handles on 25.5" do
      expect(25.ceil_for_delta(25)).to eq 25
    end
  end
end
