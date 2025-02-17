# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :supporter do
    name { "Fake Supporter Name" }
    nonprofit_id { 55352 }
    trait :has_a_card do
      after(:create) do |supporter|
        create(:active_card_1, holder: supporter)
      end
    end
  end

  factory :supporter_with_fv_poverty, class: "Supporter" do
    name { "Fake Supporter Name" }
    nonprofit { association :fv_poverty }
  end
end
