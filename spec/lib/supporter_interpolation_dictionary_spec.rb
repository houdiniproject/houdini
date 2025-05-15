# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe SupporterInterpolationDictionary do
  let(:defaults) { {"NAME" => "Supporter", "FIRSTNAME" => "Supporter"} }
  let(:sid) { SupporterInterpolationDictionary.new(defaults) }
  let(:supporter) { force_create(:supporter) }
  let(:supporter_with_empty_name) { force_create(:supporter, name: "") }
  let(:supporter_with_whitespace_name) { force_create(:supporter, name: "   ") }
  let(:supporter_with_one_word_name) { force_create(:supporter, name: "penelope") }
  let(:supporter_with_two_word_name) { force_create(:supporter, name: "penelope schultz") }
  let(:supporter_with_hyphenated_two_word_name) { force_create(:supporter, name: "penelope-rebecca schultz") }
  describe ".set_supporter" do
    it "makes no changes if supporter passed is not a Supporter" do
      sid.set_supporter("")
      expect(sid.entries).to eq(defaults)
    end

    it "makes no changes if supporter passed has no name" do
      sid.set_supporter(supporter)

      expect(sid.entries).to eq(defaults)
    end

    it "makes no changes if supporter passed has empty name" do
      sid.set_supporter(supporter_with_empty_name)

      expect(sid.entries).to eq(defaults)
    end

    it "makes no changes if supporter passed has name with only whitespace" do
      sid.set_supporter(supporter_with_whitespace_name)

      expect(sid.entries).to eq(defaults)
    end

    it "changes if supporter has only one name" do
      sid.set_supporter(supporter_with_one_word_name)

      expect(sid.entries).to eq({"NAME" => "penelope", "FIRSTNAME" => "penelope"})
    end

    it "changes if supporter has two names" do
      sid.set_supporter(supporter_with_two_word_name)

      expect(sid.entries).to eq({"NAME" => "penelope schultz", "FIRSTNAME" => "penelope"})
    end

    it "changes if supporter has hyphenated names" do
      sid.set_supporter(supporter_with_hyphenated_two_word_name)

      expect(sid.entries).to eq({"NAME" => "penelope-rebecca schultz", "FIRSTNAME" => "penelope-rebecca"})
    end
  end
end
