# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
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
