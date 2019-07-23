# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe MigrateSupporters do
    let(:nonprofit) { force_create(:nonprofit)}
  let!(:supporter_no_address) {force_create(:supporter, nonprofit: nonprofit, address: "", country: nil)}

  let!(:supporter_with_address) {force_create(:supporter, nonprofit: nonprofit, address: "addy", city: 'city', state_code: 'state', zip_code: 'zip', country: 'country')}
  
  describe '.move_supporter_to_addresses' do
    before(:each) do
      MigrateSupporters.move_supporter_to_addresses

      supporter_no_address.reload
      supporter_with_address.reload
    end

    it 'has no address on supporter without address' do
        expect(supporter_no_address.crm_addresses).to be_empty
        expect(supporter_no_address.default_address).to be_nil
    end


    it 'has an address on supporter with address' do
        expect(supporter_with_address.crm_addresses.count).to eq 1
        default_address = supporter_with_address.default_address
        expect(default_address.address).to eq 'addy'
        expect(default_address.city).to eq 'city'
        expect(default_address.state_code).to eq 'state'
        expect(default_address.zip_code).to eq 'zip'
        expect(default_address.country).to eq 'country'
    end
  end
end