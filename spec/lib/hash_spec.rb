# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require_relative "../../app/legacy_lib/hash"

describe Hash do
  describe "::with_defaults_unless_nil" do
    subject {
      Hash.with_defaults_unless_nil({new_key: "good", key_with_nil_default: nil})
    }
    it { is_expected.to eq({new_key: "good"}) }
  end
end
