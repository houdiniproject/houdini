# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertCrmAddress do
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
      result = InsertCrmAddress::create(supporter, address_data)
      expect(result).to eq CrmAddress.last
    end
  end

  describe '.find_or_create' do
    it 'should create new address when none in system already' do
      result = InsertCrmAddress::find_or_create(supporter, address_data)
      expect(result).to eq CrmAddress.last
    end

    it 'should get old address' do
      address = CrmAddress.create!({supporter:supporter}.merge(address_data))
      result = InsertCrmAddress::find_or_create(supporter, address_data)

      expect(result).to eq address

    end
  end
end