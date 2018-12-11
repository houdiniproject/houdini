# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'address_comparisons'
describe AddressComparisons do
  describe '.safely_delimited_address_string' do
    it 'mashes address together properly' do
      result = AddressComparisons.safely_delimited_address_string({one:'.rw',
                                                                  two:"wf {}} www",
                                                                  three: "!I53    "})
      result = JSON::parse(result)
      expect(result.keys.count).to eq 3
      expect(result['one']).to eq '.rw'
      expect(result['two']).to eq "wf {}} www"
      expect(result['three']).to eq "!I53    "
    end
  end

  describe '.calculate_hash' do
    it 'creates a fun hash!' do
      expected = "17dbea0da79c939a6c3835262b22c6fd7dc13aac30972bd83990ab98"
      result = AddressComparisons.calculate_hash("supporter_id", '.rw',
                                                 "wf {}} www",
                                                 "!I53    ", "zip", "country")
      expect(result).to eq expected
    end
  end
end