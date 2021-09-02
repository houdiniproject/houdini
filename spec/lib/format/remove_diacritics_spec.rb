# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Format::RemoveDiacritics do
  it '.from_hash' do 
      result = Format::RemoveDiacritics.from_hash(
        {
          "city" => "São Paulo",
          "nil_value" => nil,
          "blank_value" => "", 
          "nothing_to_change" => "Appleton"
        })
      expect(result).to eq({
        "city" => "Sao Paulo",
          "nil_value" => nil,
          "blank_value" => "", 
          "nothing_to_change" => "Appleton"
      })
  end
end

