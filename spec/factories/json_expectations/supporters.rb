# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :supporter_expectation, class: "OpenStruct" do
    id { match_houid(:supp) }
    legacy_id { be_a_kind_of(Numeric) }
    legacy_nonprofit { be_a_kind_of(Numeric) }
    deleted { false }
    object { "supporter" }
  end
end
