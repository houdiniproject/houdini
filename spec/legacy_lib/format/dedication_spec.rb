# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require_relative "../../../app/legacy_lib/format/dedication"

describe Format::Dedication do
  describe ".from_json" do
    it "returns string if not json" do
      expect(Format::Dedication.from_json("Hello there")).to eq("Hello there")
    end

    it "returns dedication with type, name, and note if json" do
      json = '{"type": "memory", "name": "Bob Ross", "note": "This is the note"}'
      expect(Format::Dedication.from_json(json)).to eq("Donation made in memory of Bob Ross. Note: This is the note")
    end
  end
end
