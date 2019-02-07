# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe CrmAddress, :type => :model do
  include_context :shared_donation_charge_context

  let(:transaction_address) { TransactionAddress.create address: '341324i890v n \n something{',
                                                        city: "cityew",
                                                        state_code: "swwwi}",
                                                        zip_code: "5234980=21jWER",
                                                        country: "UWSSSW",
                                                        supporter: supporter
  }

  let(:address){ CrmAddress.create address: '341324i890v n \n something{',
                                city: "cityew",
                                state_code: "swwwi}",
                                zip_code: "5234980=21jWER",
                                country: "UWSSSW",
                                supporter: supporter
  }
  

  it 'find_via_fingerprint' do
    address
    transaction_address
    result = CrmAddress.find_via_fingerprint(supporter, address.address, address.city, address.state_code, address.zip_code, address.country)
    expect(result).to eq address

  end

  it 'should not find CrmAddress for find_via_fingerprint' do

    transaction_address
    result = CrmAddress.find_via_fingerprint(supporter,
                                                transaction_address.address,
                                                transaction_address.city,
                                                transaction_address.state_code,
                                                transaction_address.zip_code,
                                                transaction_address.country)
    expect(result).to eq nil

  end
end
