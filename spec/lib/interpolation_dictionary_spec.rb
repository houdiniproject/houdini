# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InterpolationDictionary do
  describe ".add_entry" do
    it "accepts when provided a key we are looking for" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("NAME", "Penelope Schultz")).to be_truthy
      expect(id.entries).to eq({"NAME" => "Penelope Schultz"})
    end

    it "rejects when provided an invalid key" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("BADKEY", "Name with Key")).to be_falsy
      expect(id.entries).to eq({"NAME" => "Supporter"})
    end

    it "rejects when provided a value which is empty when santized" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("NAME", "<html> </html>")).to be_falsy
      expect(id.entries).to eq({"NAME" => "Supporter"})
    end

    it "strips out tags from a value" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("NAME", "<html>Another name<br/> <img></html>")).to be_truthy
      expect(id.entries).to eq({"NAME" => "Another name "})
    end

    it "doesnt replace value if nil" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("NAME", nil)).to be_falsey
      expect(id.entries).to eq({"NAME" => "Supporter"})
    end
  end

  describe ".interpolate" do
    it "accepts and strips out bad tags" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.add_entry("NAME", "Penelope Schultz")).to be_truthy
      str = id.interpolate("<html>{{NAME}}</html>")
      expect(str).to eq "Penelope Schultz"
    end

    it "replaces the correct variable" do
      id = InterpolationDictionary.new({"NAME" => "Supporter", "FIRSTNAME" => "Supporter"})
      expect(id.add_entry("FIRSTNAME", "Name with Key")).to be_truthy
      str = id.interpolate("Dear {{NAME}}, you are appreciated.")
      expect(str).to eq "Dear Supporter, you are appreciated."
    end

    it "returns falsy if final interpolation is empty" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.interpolate("<html> </html>")).to be_falsy
    end

    it "returns falsy if nil passed to interpolate" do
      id = InterpolationDictionary.new({"NAME" => "Supporter"})
      expect(id.interpolate(nil)).to be_falsy
    end
  end
end
