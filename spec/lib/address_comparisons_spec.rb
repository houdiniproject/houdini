# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'address_comparisons'
describe AddressComparisons do
  describe '.safely_delimited_address_string' do
    it 'mashes address together properly' do
      result = AddressComparisons.safely_delimited_address_string('.rw',
                                                                  "wf #{AddressComparisons::DELIMITER} www",
                                                                  "!I53    ")
      expect(result).to eq "RW#{AddressComparisons::DELIMITER}WF  WWW#{AddressComparisons::DELIMITER}I53"
    end
  end

  describe '.calculate_hash' do
    it 'creates a fun hash!' do
      expected = "cd5be5c5bfcdedd207f90a3a89292dfa9d284a574b06fb6ce6663651"
      result = AddressComparisons.calculate_hash('.rw',
                                                 "wf #{AddressComparisons::DELIMITER} www",
                                                 "!I53    ")
      expect(result).to eq expected
    end
  end
end