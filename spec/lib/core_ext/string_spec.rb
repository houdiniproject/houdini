# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "core_ext/string"

describe String do
  describe "#is_int?" do
    it {
      expect("5".is_int?).to be true
    }

    it {
      expect("5.41".is_int?).to be false
    }

    it {
      expect("a".is_int?).to be false
    }

    it {
      expect("1_a_string_with_non_digits_in-between-digits_5".is_int?).to be false
    }
  end
end
