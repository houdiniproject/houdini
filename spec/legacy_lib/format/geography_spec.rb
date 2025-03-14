# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require_relative "../../../app/legacy_lib/format/geography"

describe Format::Geography do
  describe ".full_state_to_code" do
    it "converts a full state name, case-insensitive, to a state code" do
      expect(Format::Geography.full_state_to_code("New mexico")).to eq("NM")
    end

    it "ignores pre-existing state codes" do
      expect(Format::Geography.full_state_to_code("NM")).to eq("NM")
    end

    it "returns nil when unrecognized" do
      expect(Format::Geography.full_state_to_code("xxyyxx")).to eq(nil)
    end
  end
end
