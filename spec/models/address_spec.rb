# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Address, :type => :model do
  include_context :shared_donation_charge_context
  let(:address_without_supporter) {Address.create address: '341324i890v n \n something',
                                                  city: "cityew",
                                                  state_code: "swwwi",
                                                  zip_code: "5234980=21jWER",
                                                  country: "UWSSSW"}
  let(:address){ Address.create address: '341324i890v n \n something{',
                                                       city: "cityew",
                                                       state_code: "swwwi}",
                                                       zip_code: "5234980=21jWER",
                                                       country: "UWSSSW",
                                                       supporter: supporter
  }

  let(:address2) { Address.create address: '341324i890v n \n something{',
                                                 city: "cityew",
                                                 state_code: "swwwi}",
                                                 zip_code: "5234980=21jWER",
                                                 country: "UWSSSW",
                                                 supporter: supporter
  }

  it 'address hash properly added' do
    expected = "581337bc8bf5173754d73b795d0a88027fad19c25175c5e5b274358b"
    expect(address.fingerprint).to eq expected
    expect(address2.fingerprint).to eq expected
  end

  it 'validates that supporter is set' do
    expect(address_without_supporter.errors['supporter']).to include('can\'t be blank')
  end
end
