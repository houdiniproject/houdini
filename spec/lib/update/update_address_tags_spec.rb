# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe UpdateAddressTags do
  include_context :shared_donation_charge_context

  it 'raises when address doesnt belong to supporter' do
    expect { UpdateAddressTags.set_default_address(supporter, other_supporter_address)}.to raise_error ActiveRecord::RecordNotFound
  end

  it 'properly sets the default when none already set' do
    result = UpdateAddressTags.set_default_address(supporter, supporter_address)
    expect(result.address).to eq supporter_address
    expect(result.supporter).to eq supporter
    expect(result.name).to eq 'default'
  end

  it 'properly sets the default when already set' do
    AddressTag.create!(supporter:supporter, address: supporter_address, name: 'default')

    result = UpdateAddressTags.set_default_address(supporter, supporter_address_2)
    expect(result.address).to eq supporter_address_2
    expect(result.supporter).to eq supporter
    expect(result.name).to eq 'default'

    expect(AddressTag.count).to eq 1
  end
end