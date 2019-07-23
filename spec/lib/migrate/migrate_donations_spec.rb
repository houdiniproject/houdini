# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe MigrateDonations do
  let(:nonprofit) { force_create(:nonprofit)}
  let!(:supporter_no_address) {force_create(:supporter, nonprofit: nonprofit, address: "", country: nil)}

  let!(:supporter_with_address) {force_create(:supporter, nonprofit: nonprofit, address: "addy", city: 'city', state_code: 'state', zip_code: 'zip', country: 'country')}
  let!(:donation_without_1) {force_create(:donation, supporter: supporter_no_address)}
  let!(:donation_without_2) {force_create(:donation, supporter: supporter_no_address)}
  let!(:donation_with_1){ force_create(:donation, supporter:supporter_with_address)}
  let!(:donation_with_2){ force_create(:donation, supporter:supporter_with_address)}

  describe '.move_addresses_to_donations' do
    before(:each) do
      MigrateDonations.move_addresses_to_donations

      donation_with_1.reload
      donation_with_2.reload
      donation_without_1.reload
      donation_without_2.reload
    end

    it 'has no address on Donation if the supporter has no address' do
      expect(donation_without_1.address).to be_nil
      expect(donation_without_2.address).to be_nil
    end

    it 'has an address on a Donation if the supporter has an address' do
      expect(donation_with_1.address.address).to eq 'addy'
      expect(donation_with_1.address.city).to eq 'city'
      expect(donation_with_1.address.state_code).to eq 'state'
      expect(donation_with_1.address.zip_code).to eq 'zip'
      expect(donation_with_1.address.country).to eq 'country'
    end

    it 'has different addresses for each transaction' do
      expect(donation_with_1.address).to_not eq donation_with_2.address
    end
  end
end