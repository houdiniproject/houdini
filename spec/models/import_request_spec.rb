# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe ImportRequest, type: :model do
  let(:import_path) { "spec/fixtures/test_import.csv" }
  let(:import_filename) { "test_import.csv" }

  let(:row_count) { 4 }
  let(:nonprofit) { create(:nm_justice) }
  let(:user) { force_create(:user) }
  let(:user_email) { user.email }
  let(:header_matches) {
    {
      "Date" => "donation.date",
      "Program" => "donation.designation",
      "Amount" => "donation.amount",
      "Business or organization name" => "supporter.organization",
      "First Name" => "supporter.first_name",
      "Last Name" => "supporter.last_name",
      "Address" => "supporter.address",
      "City" => "supporter.city",
      "State" => "supporter.state_code",
      "Zip Code" => "supporter.zip_code",
      "EMAIL" => "supporter.email",
      "notes" => "donation.comment",
      "Field Guy" => "custom_field",
      "Tag 1" => "tag",
      "Tag 2" => "tag"
    }
  }

  describe "successful" do
    around do |example|
      Timecop.freeze(2020, 5, 5) do
        example.run
      end
    end

    let(:request) {
      ir = ImportRequest.new(nonprofit: nonprofit, header_matches: header_matches, user_email: user_email)
      ir.import_file.attach(io: File.open(import_path), filename: import_filename)
      ir.save!
      ir
    }

    let!(:import) { request.execute(user) }

    let(:donations) { Supporter.all.map(&:donations).flatten }

    it "creates an Import with all the correct data" do
      expect(import.nonprofit).to eq(nonprofit)
      expect(import.id).to be_present
      expect(import.row_count).to eq row_count
      expect(import.date).to eq(import.created_at)
      expect(import.user_id).to eq(user.id)
      expect(import.imported_count).to eq(16)
    end

    it "deleted the import request" do
      expect(ImportRequest.where(id: request.id).count).to eq 0
    end

    it "creates all the supporters with correct names" do
      names = Supporter.pluck(:name)
      expect(names).to match_array ["Robert Norris", "Angie Vaughn", "Bill Waddell", "Bubba Thurmond"]
    end

    it "creates all the supporters with correct emails" do
      emails = Supporter.pluck(:email)
      expect(emails).to match_array(["user@example.com", "user@example.com", "user@example.com", "user@example.com"])
    end

    it "creates all the supporters with correct organizations" do
      orgs = Supporter.pluck(:organization)
      expect(orgs).to match_array ["Jet-Pep", "Klein Drug Shoppe, Inc.", "River City Equipment Rental and Sales", "Somewhere LLC"]
    end

    it "creates all the supporters with correct cities" do
      cities = Supporter.pluck(:city)
      expect(cities).to match_array ["Decatur", "Guntersville", "Holly Pond", "Snead"]
    end

    it "creates all the supporters with correct addresses" do
      addresses = Supporter.pluck(:address)
      expect(addresses).to match_array(["3370 Alabama Highway 69", "649 Finley Island Road", "P.O. Box 143", "P.O. Box 611"])
    end

    it "creates all the supporters with correct zip_codes" do
      zips = Supporter.pluck(:zip_code)
      expect(zips).to match_array(["35601", "35806", "35952", "35976"])
    end

    it "creates all the supporters with correct state_codes" do
      states = Supporter.pluck(:state_code)
      expect(states).to match_array(["AL", "AL", "AL", "AL"])
    end

    it "creates all the donations with correct amounts" do
      amounts = donations.map { |d| d["amount"] }
      expect(amounts).to match_array([1000, 1000, 1000, 1000])
    end

    it "creates all the donations with correct designations" do
      desigs = donations.map { |d| d["designation"] }
      expect(desigs).to match_array(["third party event", "third party event", "third party event", "third party event"])
    end

    it "inserts custom fields" do
      vals = CustomFieldJoin.pluck(:value)
      expect(vals).to match_array(["custfield", "custfield", "custfield", "custfield"])
    end
    it "inserts tags" do
      names = TagJoin.joins(:tag_definition).pluck("tag_definitions.name")
      expect(names).to match_array(%w[tag1 tag1 tag1 tag1 tag2 tag2 tag2 tag2])
    end
  end
end
