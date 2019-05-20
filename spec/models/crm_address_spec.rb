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


  let(:identical_undeleted_address){ CrmAddress.create address: '341324i890v n \n something{',
    city: "cityew",
    state_code: "swwwi}",
    zip_code: "5234980=21jWER",
    country: "UWSSSW",
    supporter: supporter
}

  let(:identical_deleted_address){ CrmAddress.create address: '341324i890v n \n something{',
    city: "cityew",
    state_code: "swwwi}",
    zip_code: "5234980=21jWER",
    country: "UWSSSW",
    supporter: supporter,
    deleted:true
}

  let(:deleted_address){ CrmAddress.create address: ' n \n something{',
    city: "cityew",
    state_code: "swwwi}",
    zip_code: "5234980=21jWER",
    country: "UWSSSW",
    supporter: supporter,
    deleted: true
}
  

  it 'find_via_fingerprint' do
    identical_undeleted_address
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

  it 'should not find a deleted CrmAddress for find_via_fingerprint' do

    transaction_address
    deleted_address
    result = CrmAddress.find_via_fingerprint(supporter,
                                                deleted_address.address,
                                                deleted_address.city,
                                                deleted_address.state_code,
                                                deleted_address.zip_code,
                                                deleted_address.country)
    expect(result).to eq nil

  end

  it 'should not find a deleted CrmAddress for find_via_fingerprint' do

    transaction_address
    deleted_address
    result = CrmAddress.find_via_fingerprint(supporter,
                                                deleted_address.address,
                                                deleted_address.city,
                                                deleted_address.state_code,
                                                deleted_address.zip_code,
                                                deleted_address.country)
    expect(result).to eq nil

  end

  it 'should find a undeleted CrmAddress for find_via_fingerprint' do

    transaction_address
    address
    identical_deleted_address
    result = CrmAddress.find_via_fingerprint(supporter,
      identical_deleted_address.address,
      identical_deleted_address.city,
      identical_deleted_address.state_code,
      identical_deleted_address.zip_code,
      identical_deleted_address.country)
    expect(result).to eq address

  end
end
