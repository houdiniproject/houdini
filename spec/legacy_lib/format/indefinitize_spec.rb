# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require_relative '../../../app/legacy_lib/format/indefinitize'

describe Format::Indefinitize do
  describe '#article' do
    it 'returns an for string starting with vowel' do
      expect(Format::Indefinitize.article('apple')).to eq('an')
    end

    it 'returns a for string not starting with vowel' do
      expect(Format::Indefinitize.article('bear')).to eq('a')
    end
  end

  describe '#with_article' do
    it 'returns an and word for string starting with vowel' do
      expect(Format::Indefinitize.with_article('apple')).to eq('an apple')
    end

    it 'returns a and word for not string starting with vowel' do
      expect(Format::Indefinitize.with_article('bear')).to eq('a bear')
    end
  end
end
