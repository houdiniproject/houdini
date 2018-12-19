# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertCustomAddress do
  include_context :shared_rd_donation_value_context
  let(:address_data) {
    {
      'address': 'address',
      'city': 'city',
      'state_code': 'state',
      'zip_code': 'zipppy zip',
      'country': 'country code'
    }
  }
  describe '.create' do
    it 'should create custom address and notify of creation' do
      address_strategy = double('address_strategy')
      expect(address_strategy).to receive(:on_add).once
      expect(supporter).to receive(:default_address_strategy).and_return(address_strategy)

      result = InsertCustomAddress::create(supporter, address_data)
      expect(result).to eq CustomAddress.last
    end
  end

  describe '.find_or_create' do
    it 'should create new address when none in system already' do
      address_strategy = double('address_strategy')
      expect(address_strategy).to receive(:on_add).once
      expect(supporter).to receive(:default_address_strategy).and_return(address_strategy)

      result = InsertCustomAddress::find_or_create(supporter, address_data)
      expect(result).to eq CustomAddress.last
    end

    it 'should get old address' do
      address_strategy = double('address_strategy')
      expect(address_strategy).to_not receive(:on_add)
      allow(supporter).to receive(:default_address_strategy).and_return(address_strategy)

      address = CustomAddress.create!({supporter:supporter}.merge(address_data))
      result = InsertCustomAddress::find_or_create(supporter, address_data)

      expect(result).to eq address

    end
  end
end