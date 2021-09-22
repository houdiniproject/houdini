# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertImport  do

  describe 'parsing' do

  let(:user) { create(:user)}
  subject(:import_result) do
    import = InsertImport.from_csv(
      nonprofit_id: create(:fv_poverty).id,
      user_email: user.email, 
      user_id: user.id,
      file_uri: "#{ENV['PWD']}/spec/fixtures/test_import.csv",
      header_matches: {
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
      })

  

    Import.find(import['id'])
  end

  it { expect{import_result}.to change{Supporter.count}.by(5)}
  it { expect{import_result}.to change{Payment.count}.by(5)}

  describe 'import for user@example1.com' do 
    subject { 
      import_result
      Supporter.find_by_email("user@example1.com")
    }

    it do 
      is_expected.to have_attributes(
        donations: 
          a_collection_containing_exactly(
            an_instance_of(Donation).and have_attributes(amount: 1000)
          )
      )
    end
    it { 
      is_expected.to have_attributes(
        address: 'P.O. Box 611',
        city: 'Snead',
        state_code: 'AL',
        zip_code: '35952'
      )
    }
  end

  describe 'import for user2@example2.com' do 
    subject { 
      import_result
      Supporter.find_by_email("user2@example2.com")
    }

    it do 
      is_expected.to have_attributes(
        donations: 
          a_collection_containing_exactly(
            an_instance_of(Donation).and have_attributes(amount: 1040)
          )
      )
    end

    it { 
      is_expected.to have_attributes(
        address: 'P.O. Box 143',
        city: 'Holly Pond',
        state_code: 'AL',
        zip_code: '35806'
      )
    }
  end

  describe 'import for user5@example.com' do 
    subject { 
      import_result
      Supporter.find_by_email("user5@example.com")
    }

    it do 
      is_expected.to have_attributes(
        donations: 
          a_collection_containing_exactly(
            an_instance_of(Donation).and have_attributes(amount: 0)
          )
      )
    end
    it { 
      is_expected.to have_attributes(
        address: nil,
        city: 'Guntersville',
        state_code: 'WI',
        zip_code: '54915'
      )
    }
  end


  describe 'import for Bill Waddell' do 
    subject { 
      import_result
      Supporter.find_by_name("Bill Waddell")
    }

    it do 
      is_expected.to have_attributes(
        donations: 
          a_collection_containing_exactly(
            an_instance_of(Donation).and have_attributes(amount: 1000)
          )
      )
    end
    it do 
      is_expected.to have_attributes(
        name: 'Bill Waddell',
        email: 'user@example.com',
        address: '649 Finley Island Road',
        city: 'Decatur',
        state_code: 'AL',
        zip_code: '35601'
      )
    end
  end

  describe 'import for Bubba Thurmond' do 
    subject { 
      import_result
      Supporter.find_by_name("Bubba Thurmond")
    }

    it do 
      is_expected.to have_attributes(
        donations: 
          a_collection_containing_exactly(
            an_instance_of(Donation).and have_attributes(amount: 1000)
          )
      )
    end
    it do 
      is_expected.to have_attributes(
        name: 'Bubba Thurmond',
        email: 'user@example.com',
        address: '3370 Alabama Highway 69',
        city: 'Guntersville',
        state_code: 'AL',
        zip_code: '35976'
      )
    end
  end
end

  # describe '.from_csv' do
  #   before(:all) do
  #     # @row_count = 4
  #     # @args = {
  #     #   nonprofit_id: @data['np']['id'],
  #     #   user_email: @data['np_admin']['email'],
  #     #   user_id: @data['np_admin']['id'],
  #     #   file_uri: "#{ENV['PWD']}/spec/fixtures/test_import.csv",
  #     #   header_matches: {
  #     #     "Date" => "donation.date",
  #     #     "Program" => "donation.designation",
  #     #     "Amount" => "donation.amount",
  #     #     "Business or organization name" => "supporter.organization",
  #     #     "First Name" => "supporter.first_name",
  #     #     "Last Name" => "supporter.last_name",
  #     #     "Address" => "supporter.address",
  #     #     "City" => "supporter.city",
  #     #     "State" => "supporter.state_code",
  #     #     "Zip Code" => "supporter.zip_code",
  #     #     "EMAIL" => "supporter.email",
  #     #     "notes" => "donation.comment",
  #     #     "Field Guy" => "custom_field",
  #     #     "Tag 1" => "tag",
  #     #     "Tag 2" => "tag"
  #     #   }
  #     # }
  #     # @result = InsertImport.from_csv(@args)
  #     # @supporters = Psql.execute("SELECT * FROM supporters WHERE import_id = #{@result['id']}")
  #     # @supporter_ids = @supporters.map{|h| h['id']}
  #     # @donations = Psql.execute("SELECT * FROM donations WHERE supporter_id IN (#{@supporter_ids.join(",")})")
  #   end

  #   it 'creates an import table with all the correct data' do
  #     expect(@result['nonprofit_id']).to eq(@data['np']['id'])
  #     expect(@result['id']).to be_present
  #     expect(@result['row_count']).to eq @row_count
  #     expect(@result['date']).to eq(@result['created_at'])
  #     expect(@result['user_id']).to eq(@data['np_admin']['id'])
  #     expect(@result['imported_count']).to eq(16)
  #   end


  #   it 'creates all the supporters with correct names' do
  #     names = @supporters.map{|s| s['name']}
  #     expect(names.sort).to eq(Hamster::Vector["Robert Norris", "Angie Vaughn", "Bill Waddell", "Bubba Thurmond"].sort)
  #   end

  #   it 'creates all the supporters with correct emails' do
  #     emails = @supporters.map{|s| s['email']}
  #     expect(emails.sort).to eq(Hamster::Vector["user@example.com", "user@example.com", "user@example.com", "user@example.com"].sort)
  #   end

  #   it 'creates all the supporters with correct organizations' do
  #     orgs = @supporters.map{|s| s['organization']}
  #     expect(orgs.sort).to eq(Hamster::Vector["Jet-Pep", "Klein Drug Shoppe, Inc.", "River City Equipment Rental and Sales", "Somewhere LLC"].sort)
  #   end

  #   it 'creates all the supporters with correct cities' do
  #     cities = @supporters.map{|s| s['city']}
  #     expect(cities.sort).to eq(Hamster::Vector["Decatur", "Guntersville", "Holly Pond", "Snead"].sort)
  #   end

  #   it 'creates all the supporters with correct addresses' do
  #     addresses = @supporters.map{|s| s['address']}
  #     expect(addresses.sort).to eq(Hamster::Vector["3370 Alabama Highway 69", "649 Finley Island Road", "P.O. Box 143", "P.O. Box 611"].sort)
  #   end

  #   it 'creates all the supporters with correct zip_codes' do
  #     zips = @supporters.map{|s| s['zip_code']}
  #     expect(zips.sort).to eq(Hamster::Vector["35601", "35806", "35952", "35976"].sort)
  #   end

  #   it 'creates all the supporters with correct state_codes' do
  #     states = @supporters.map{|s| s['state_code']}
  #     expect(states.sort).to eq(Hamster::Vector["AL", "AL", "AL", "AL"])
  #   end

  #   it 'creates all the donations with correct amounts' do
  #     amounts = @donations.map{|d| d['amount']}
  #     expect(amounts.sort).to eq(Hamster::Vector[1000, 1000, 1000, 1000])
  #   end

  #   it 'creates all the donations with correct designations' do
  #     desigs = @donations.map{|d| d['designation']}
  #     expect(desigs.sort).to eq(Hamster::Vector["third party event", "third party event", "third party event", "third party event"])
  #   end

  #   it 'inserts custom fields' do
  #     vals = Psql.execute("SELECT value FROM custom_field_joins ORDER BY id DESC LIMIT 4").map{|h| h['value']}
  #     expect(vals).to eq(Hamster::Vector["custfield", "custfield", "custfield", "custfield"])
  #   end

  #   it 'inserts tags' do
  #     ids = @supporters.map{|h| h['id']}.join(", ")
  #     names = Psql.execute("SELECT tag_masters.name FROM tag_joins JOIN tag_masters ON tag_masters.id=tag_joins.tag_master_id WHERE tag_joins.supporter_id IN (#{ids})")
  #       .map{|h| h['name']}
  #     expect(Hamster.to_ruby(names).sort).to eq(["tag1", "tag1", "tag1", "tag1", "tag2", "tag2", "tag2", "tag2"])
  #   end

  # end
end
