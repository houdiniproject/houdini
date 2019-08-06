# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertImport::ImportExecution do
  include_context :shared_rd_donation_value_context

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

  let (:file_uri) {(Rails.root + 'spec/fixtures/test_import.csv').to_s}
  let (:penelope) {Supporter.where(name: 'Penelope Schultz').first}

  describe '.from_csv' do

    let(:executor) do
      InsertImport::ImportExecution.new(nonprofit, user, header_matches)
    end

    let(:load_from_file) do
      executor.from_csv(file_uri)
    end

    let (:payments) {Payment.all}

    let(:default_addresses) { Supporter.all.map{|s| s.default_address}}

    before(:each) {
      allow(QueueDonations).to receive(:execute_for_donation)
      expect_email_queued.with(JobTypes::ImportCompleteNotificationJob,
                               kind_of(Numeric))
      load_from_file
    }

    it 'should create supporters with correct name' do
      result = Supporter.pluck(:name)
      expect(result).to match_array(["Robert Norris", "Angie Vaughn", "Bill Waddell", "Bubba Thurmond", "Penelope Schultz"])
    end

    it 'should create 5 payments' do
      expect(payments.count).to eq 5
    end

    it 'should create 5 TransactionAddresses' do
      expect(TransactionAddress.count).to eq 5
    end

    it 'should create with correct emails' do
      result = Supporter.pluck(:email)
      expect(result).to match_array(['user@example1.com', 'user@example2.com',
                                     'user@example.com',
                                     'bubba@example.com',
                                     'penelope@penelope.home.com'
                                    ])
    end

    it 'should creates all the supporters with correct organizations' do
      result = Supporter.pluck(:organization)
      expect(result).to match_array(["Jet-Pep", "Klein Drug Shoppe, Inc.", "River City Equipment Rental and Sales", "Somewhere LLC", "Somewhere LLC"])
    end

    it 'should have correct default cities' do
      result = default_addresses.map{|a| a.city}
      expect(result).to match_array(["Decatur", "Guntersville", "Holly Pond", "Snead", 'Guntersville'])
    end

    it 'should have correct default address' do
      result = default_addresses.map{|a| a.address}
      expect(result).to match_array(["3370 Alabama Highway 69",
                                     "649 Finley Island Road",
                                     "P.O. Box 143",
                                     "P.O. Box 611",
                                     '5555105 Fun'])
    end

    it 'should create all the supporters with correct zip_codes' do
      result = default_addresses.map{|a| a.zip_code}
      expect(result).to match_array(["35601", "35806", "35952", "35976", "35976"])
    end

    it 'should create all the supporters with correct state_codes' do
      result = default_addresses.map{|a| a.state_code}
      expect(result).to match_array(["AL", "AL", "AL", "AL", "AL"])
    end


    it 'should create all the donations with correct amounts' do
      result = payments.map{|i| i.gross_amount}
      expect(result).to match_array([1000, 1000, 1000, 1000, 2000])
    end

    it 'should create all the donations with correct designations' do
      desigs = payments.map{|p| p.donation}.map{|d| d.designation}
      expect(desigs).to match_array(["third party event", "third party event", "third party event", "third party event", nil])
    end

    it 'should create the correct custom fields values' do
      result = Supporter.all.map{|s| s.custom_field_joins.first}.map{|cfj| cfj ? cfj.value : nil}
      expect(result).to match_array(["custfield","custfield","custfield","custfield",nil])
    end

    it 'should have the correct custom field' do
      expect(CustomFieldMaster.count).to eq 1
    end

    it 'should have the correct tags' do
      result = Supporter.all.map{|t| t.tag_joins}.map{|i| i.map{|m| m.name}}
      expect(result).to match_array([ ["tag1", 'tag2'], ["tag1", 'tag2'], ["tag1", 'tag2'], ["tag1", 'tag2'], []])
    end

    it 'should have one crm address for Penelope' do
      expect(CrmAddress.where(supporter_id: penelope.id).count).to eq 1
    end

    it 'should have two custom address' do
      expect(CrmAddress.count).to eq 5
    end

    it 'should have one transaction address' do
      expect(TransactionAddress.count).to eq 5
    end

    it 'should only have one transaction address per transaction' do
      count = TransactionAddress.group(:transactionable_type, :transactionable_id).count

      count.each do |k,v|
        expect(v).to eq 1
      end
    end
  end
end

