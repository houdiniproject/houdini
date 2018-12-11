# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CalculateDefaultAddressStrategy do
  it 'returns ManualStrategy on manual' do
    default_result = CalculateDefaultAddressStrategy.find_strategy()
    expect(default_result).to be_an_instance_of DefaultAddressStrategies::ManualStrategy

    result = CalculateDefaultAddressStrategy.find_strategy(:manual)
    expect(result).to be_an_instance_of DefaultAddressStrategies::ManualStrategy
  end

  it 'returns AlwaysFirstStrategy on always_first' do
    result = CalculateDefaultAddressStrategy.find_strategy(:always_first)
    expect(result).to be_an_instance_of DefaultAddressStrategies::AlwaysFirstStrategy
  end

  it 'returns AlwaysLastStrategy on always_last' do
    result = CalculateDefaultAddressStrategy.find_strategy(:always_last)
    expect(result).to be_an_instance_of DefaultAddressStrategies::AlwaysLastStrategy
  end
end