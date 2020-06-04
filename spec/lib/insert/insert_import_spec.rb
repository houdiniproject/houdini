# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertImport, pending: true do
  before(:all) do
    # @data = PsqlFixtures.init
  end

  describe '.from_csv' do
    before(:all) do
      # @row_count = 4
      # @args = {
      #   nonprofit_id: @data['np']['id'],
      #   user_email: @data['np_admin']['email'],
      #   user_id: @data['np_admin']['id'],
      #   file_uri: "#{ENV['PWD']}/spec/fixtures/test_import.csv",
      #   header_matches: {
      #     "Date" => "donation.date",
      #     "Program" => "donation.designation",
      #     "Amount" => "donation.amount",
      #     "Business or organization name" => "supporter.organization",
      #     "First Name" => "supporter.first_name",
      #     "Last Name" => "supporter.last_name",
      #     "Address" => "supporter.address",
      #     "City" => "supporter.city",
      #     "State" => "supporter.state_code",
      #     "Zip Code" => "supporter.zip_code",
      #     "EMAIL" => "supporter.email",
      #     "notes" => "donation.comment",
      #     "Field Guy" => "custom_field",
      #     "Tag 1" => "tag",
      #     "Tag 2" => "tag"
      #   }
      # }
      # @result = InsertImport.from_csv(@args)
      # @supporters = Psql.execute("SELECT * FROM supporters WHERE import_id = #{@result['id']}")
      # @supporter_ids = @supporters.map{|h| h['id']}
      # @donations = Psql.execute("SELECT * FROM donations WHERE supporter_id IN (#{@supporter_ids.join(",")})")
    end

    it 'creates an import table with all the correct data' do
      expect(@result['nonprofit_id']).to eq(@data['np']['id'])
      expect(@result['id']).to be_present
      expect(@result['row_count']).to eq @row_count
      expect(@result['date']).to eq(@result['created_at'])
      expect(@result['user_id']).to eq(@data['np_admin']['id'])
      expect(@result['imported_count']).to eq(16)
    end

    it 'creates all the supporters with correct names' do
      names = @supporters.map { |s| s['name'] }
      expect(names.sort).to eq(Hamster::Vector['Robert Norris', 'Angie Vaughn', 'Bill Waddell', 'Bubba Thurmond'].sort)
    end

    it 'creates all the supporters with correct emails' do
      emails = @supporters.map { |s| s['email'] }
      expect(emails.sort).to eq(Hamster::Vector['user@example.com', 'user@example.com', 'user@example.com', 'user@example.com'].sort)
    end

    it 'creates all the supporters with correct organizations' do
      orgs = @supporters.map { |s| s['organization'] }
      expect(orgs.sort).to eq(Hamster::Vector['Jet-Pep', 'Klein Drug Shoppe, Inc.', 'River City Equipment Rental and Sales', 'Somewhere LLC'].sort)
    end

    it 'creates all the supporters with correct cities' do
      cities = @supporters.map { |s| s['city'] }
      expect(cities.sort).to eq(Hamster::Vector['Decatur', 'Guntersville', 'Holly Pond', 'Snead'].sort)
    end

    it 'creates all the supporters with correct addresses' do
      addresses = @supporters.map { |s| s['address'] }
      expect(addresses.sort).to eq(Hamster::Vector['3370 Alabama Highway 69', '649 Finley Island Road', 'P.O. Box 143', 'P.O. Box 611'].sort)
    end

    it 'creates all the supporters with correct zip_codes' do
      zips = @supporters.map { |s| s['zip_code'] }
      expect(zips.sort).to eq(Hamster::Vector['35601', '35806', '35952', '35976'].sort)
    end

    it 'creates all the supporters with correct state_codes' do
      states = @supporters.map { |s| s['state_code'] }
      expect(states.sort).to eq(Hamster::Vector['AL', 'AL', 'AL', 'AL'])
    end

    it 'creates all the donations with correct amounts' do
      amounts = @donations.map { |d| d['amount'] }
      expect(amounts.sort).to eq(Hamster::Vector[1000, 1000, 1000, 1000])
    end

    it 'creates all the donations with correct designations' do
      desigs = @donations.map { |d| d['designation'] }
      expect(desigs.sort).to eq(Hamster::Vector['third party event', 'third party event', 'third party event', 'third party event'])
    end

    it 'inserts custom fields' do
      vals = Psql.execute('SELECT value FROM custom_field_joins ORDER BY id DESC LIMIT 4').map { |h| h['value'] }
      expect(vals).to eq(Hamster::Vector['custfield', 'custfield', 'custfield', 'custfield'])
    end

    it 'inserts tags' do
      ids = @supporters.map { |h| h['id'] }.join(', ')
      names = Psql.execute("SELECT tag_masters.name FROM tag_joins JOIN tag_masters ON tag_masters.id=tag_joins.tag_master_id WHERE tag_joins.supporter_id IN (#{ids})")
                  .map { |h| h['name'] }
      expect(Hamster.to_ruby(names).sort).to eq(%w[tag1 tag1 tag1 tag1 tag2 tag2 tag2 tag2])
    end
  end
end
