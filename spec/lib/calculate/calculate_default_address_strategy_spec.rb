# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CalculateDefaultAddressStrategy do
  it 'returns ManualStrategy on manual' do
    default_result = CalculateDefaultAddressStrategy.find_strategy()
    expect(default_result).to eq DefaultAddressStrategies::ManualStrategy

    result = CalculateDefaultAddressStrategy.find_strategy(:manual)
    expect(result).to eq DefaultAddressStrategies::ManualStrategy
  end

  it 'returns AlwaysFirstStrategy on always_first' do
    result = CalculateDefaultAddressStrategy.find_strategy(:always_first)
    expect(result).to eq DefaultAddressStrategies::AlwaysFirstStrategy
  end

  it 'returns AlwaysLastStrategy on always_last' do
    result = CalculateDefaultAddressStrategy.find_strategy(:always_last)
    expect(result).to eq DefaultAddressStrategies::AlwaysLastStrategy
  end
end