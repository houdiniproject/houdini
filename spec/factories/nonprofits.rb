# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :nonprofit do
    name {"spec_nonprofit_full"}
    city {'Albuquerque'}
    state_code {'NM'}
    zip_code {55555}
    email {"example@email.com"}
    slug {'sluggy-sluggo'}
    billing_subscription {build(:billing_subscription, billing_plan: build(:billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat))}
    vetted { true }

    factory :nonprofit_with_cards do
      after(:create) {|nonprofit, evaluator|
        create(:active_card_1, holder:nonprofit)
        create(:active_card_2, holder:nonprofit)
        create(:inactive_card, holder:nonprofit)
      }
    end

    factory :nonprofit_with_billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat do 
      
    end

    factory :nonprofit_with_billing_plan_percentage_fee_of_2_5_with_fee_era do 
      
    end

    factory :nonprofit_with_no_billing_subscription do 
      billing_subscription { nil}
    end

    factory :nonprofit_with_activated_deactivation_record do
      nonprofit_deactivation { build(:nonprofit_deactivation, deactivated: false)}
    end

    factory :nonprofit_with_deactivated_deactivation_record do
      nonprofit_deactivation { build(:nonprofit_deactivation, deactivated: true)}
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
    sequence(:slug) { |n| "#{n}-end-poverty-in-the-fox-valley-inc" }
    state_code_slug { 'wi'}
    city_slug { 'appleton'}
    billing_subscription {build(:billing_subscription, billing_plan: build(:billing_plan_percentage_fee_of_2_5_percent_and_5_cents_flat))}
  end

  factory :nonprofit_base, class: 'Nonprofit' do
    name { 'Ending Poverty in the Fox Valley Inc.' }
    city { 'Appleton '}
    state_code { 'wi'}
    sequence(:slug) { |n| "#{n}-end-poverty-in-the-fox-valley-inc" }
    state_code_slug { 'wi'}
    city_slug { 'appleton'}

    trait :activated_deactivation_record do
      nonprofit_deactivation { association :nonprofit_deactivation, deactivated: false }
    end
    trait :deactivate_nonprofit do
      nonprofit_deactivation { association :nonprofit_deactivation, deactivated: true }
    end

    trait :with_default_billing_subscription do
      billing_subscription
    end

    trait :with_active_card_on_stripe do
      active_card {association :card_base, :with_created_stripe_customer_and_card}
      
    end

    trait :with_billing_subscription_on_stripe do
      transient do
        billing_plan {}
      end
      with_active_card_on_stripe
      billing_subscription { 
        attributes = {
          
          stripe_customer: active_card.stripe_customer
        }
        if billing_plan
          attributes[:billing_plan] = billing_plan
        end
        association :billing_subscription, 
        :with_associated_stripe_subscription,
        nonprofit: @instance,
        **attributes
        }
    end


    trait :with_inactive_tag do
      after(:create) do |nonprofit, evaluator|
        nonprofit.tag_masters << build(:tag_master_base, deleted:true)
        nonprofit.save
      end
    end

    trait :with_active_tag do
      after(:create) do |nonprofit, evaluator|
        nonprofit.tag_masters << build(:tag_master_base)
        nonprofit.save
      end
    end

    trait :with_active_mailing_list do
      after(:create) do |nonprofit, evaluator|
        nonprofit.tag_masters << build(:tag_master_base, :with_email_list, nonprofit:nonprofit)
        nonprofit.save
      end
    end

    trait :with_inactive_mailing_list do
      after(:create) do |nonprofit, evaluator|
        nonprofit.tag_masters << build(:tag_master_base, :with_email_list, deleted:true, nonprofit:nonprofit)
        nonprofit.save
      end
    end

    trait :with_old_billing_plan_on_stripe do

      with_active_card_on_stripe
      billing_subscription { association :billing_subscription, 
        :with_associated_stripe_subscription, 
        stripe_customer: active_card.stripe_customer,
        billing_plan: create(:billing_plan_base, :with_associated_stripe_plan, amount: 133333, percentage_fee: 0.33, name: "fake plan")
      }
    end

    
  end
end
