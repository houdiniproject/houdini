# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :nonprofit do
    name "spec_nonprofit_full"
    city 'Albuquerque'
    state_code 'NM'
    zip_code 55555
    email "example@email.com"
    slug 'sluggy-sluggo'
    billing_subscription {build(:billing_subscription, billing_plan: build(:billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat))}

    factory :nonprofit_with_cards do
      after(:create) {|nonprofit, evaluator|
        create(:active_card_1, holder:nonprofit)
        create(:active_card_2, holder:nonprofit)
        create(:inactive_card, holder:nonprofit)
      }
    end

    after(:create) {|nonprofit, evaluator|
      create(:supporter, nonprofit: nonprofit)
    }

    factory :nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat do 
      
    end

    factory :nonprofit_with_billing_plan_percentage_fee_of_2_5_with_fee_era do 
      
    end

    factory :nonprofit_with_no_billing_subscription do 
      billing_subscription { nil}
    end
  end

  factory :fv_poverty, class: Nonprofit do
    id { 22352 }
    name { 'Ending Poverty in the Fox Valley Inc.' }
    city { 'Appleton' }
    state_code { 'WI' }
    zip_code { 54915 }
    email { 'contact@endpovertyinthefoxvalleyinc.org' }
    website {'https://endpovertyinthefoxvalleyinc.org'}
    slug { 'end-poverty-in-the-fox-valley-inc' }
    state_code_slug { 'wi'}
    city_slug { 'appleton'}
  end
end
