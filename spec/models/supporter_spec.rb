# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Supporter, :type => :model do
  include_context :shared_donation_charge_context
  let(:crm_address){ CrmAddress.create address: '341324i890v n \n something',
                                                       city: "cityew",
                                                       state_code: "swwwi",
                                                       zip_code: "5234980=21jWER",
                                                       country: "UWSSSW",
                                                       supporter: supporter
  }

  let(:default_address_to_crm) { crm_address.address_tags.create(name:"default", supporter: supporter)}

  it 'sets default address to nil when none set' do
    expect(supporter.default_address).to be_nil
  end

  it 'sets default address to a custom Address when set' do
    default_address_to_crm
    result = supporter.default_address
    expect(result.class).to be CrmAddress
  end
end
