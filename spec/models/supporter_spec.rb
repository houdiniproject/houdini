# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Supporter, :type => :model do
  include_context :shared_donation_charge_context
  let(:custom_address){ CustomAddress.create address: '341324i890v n \n something',
                                                       city: "cityew",
                                                       state_code: "swwwi",
                                                       zip_code: "5234980=21jWER",
                                                       country: "UWSSSW",
                                                       supporter: supporter
  }

  let(:transaction_address){ TransactionAddress.create address: 'Address2',
                                city: "cityew",
                                state_code: "swwwi",
                                zip_code: "5234980=21jWER",
                                country: "UWSSSW",
                                supporter: supporter
  }

  let(:default_address_to_transaction) { transaction_address.address_tags.create(name:"default", supporter: supporter)}
  let(:default_address_to_custom) { custom_address.address_tags.create(name:"default", supporter: supporter)}

  it 'sets default address to nil when none set' do
    expect(supporter.default_address).to be_nil
  end

  it 'sets default address to a transaction Address when set' do
    default_address_to_transaction
    result = supporter.default_address
    expect(result.class).to be TransactionAddress
  end

  it 'sets default address to a custom Address when set' do
    default_address_to_custom
    result = supporter.default_address
    expect(result.class).to be CustomAddress
  end
end
