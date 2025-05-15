# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :charge do
    stripe_charge_id { "ch_test_id" }
  end

  factory :charge_base, class: "Charge" do
    stripe_charge_id { "ch_test_id" }
    nonprofit { supporter.nonprofit }
    supporter { association :supporter_base }
  end
end
