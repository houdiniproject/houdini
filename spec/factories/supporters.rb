# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :supporter do
    name "Fake Supporter Name"
    nonprofit

    trait :has_a_card do
      after(:create) {|supporter|
        create(:active_card_1, holder: supporter)
      }
    end
  end
  factory :supporter_with_fv_poverty, class: 'Supporter' do
    name { 'Fake Supporter Name' }
    nonprofit { association :fv_poverty}

    trait :with_primary_address do
      addresses { [build(:supporter_address)]}
      primary_address { addresses.first}
    end
  end
end
