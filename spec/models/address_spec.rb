# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Address, :type => :model do
  include_context :shared_donation_charge_context
  let(:address_without_supporter) {CrmAddress.create address: '341324i890v n \n something',
                                                  city: "cityew",
                                                  state_code: "swwwi",
                                                  zip_code: "5234980=21jWER",
                                                  country: "UWSSSW"}
  let(:address){ CrmAddress.create address: '341324i890v n \n something{',
                                                       city: "cityew",
                                                       state_code: "swwwi}",
                                                       zip_code: "5234980=21jWER",
                                                       country: "UWSSSW",
                                                       supporter: supporter
  }

  let(:address2) { CrmAddress.create address: '341324i890v n \n something{',
                                                 city: "cityew",
                                                 state_code: "swwwi}",
                                                 zip_code: "5234980=21jWER",
                                                 country: "UWSSSW",
                                                 supporter: supporter
  }

  it 'address hash properly added' do
    expect(address.fingerprint).to eq address2.fingerprint
  end

  it 'validates that supporter is set' do
    expect(address_without_supporter.errors['supporter']).to include('can\'t be blank')
  end

  it 'find_via_fingerprint' do
    result = CrmAddress.find_via_fingerprint(supporter, address.address, address.city, address.state_code, address.zip_code, address.country)
    expect(result).to eq address
  end

  it 'cant find via fingerprint' do
    result = CrmAddress.find_via_fingerprint(supporter,
                                          address.address+"something not in db",
                                          address.city,
                                          address.state_code,
                                          address.zip_code,
                                          address.country)

    expect(result).to be_nil

  end
end
