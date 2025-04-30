# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :donation do
  end

  factory :donation_base, class: "Donation" do
    nonprofit { supporter.nonprofit }
    amount { 333 }
    factory :donation_base_with_supporter, class: "Donation" do
      supporter { build(:supporter_base) }
    end

    trait :and_campaign_gift do
      campaign { build(:campaign_with_things_set_1, nonprofit: nonprofit) }
      campaign_gifts {
        [
          build(
            :campaign_gift,
            campaign_gift_option: build(
              :campaign_gift_option,
              campaign: campaign
            )
          )
        ]
      }
    end

    factory :donation_with_dedication do
      dedication {
        {
          contact: {
            email: "email@ema.com",
            phone: "234-343-3234",
            address: "123 Four"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        }.to_json
      }
    end
  end

  factory :fv_poverty_donation, class: "Donation" do
    nonprofit { association :fv_poverty }

    supporter { build(:supporter_with_fv_poverty, nonprofit: nonprofit) }
    amount { 333 }
    factory :donation_with_dedication_designation do
      dedication {
        {
          contact: {
            email: "email@ema.com"
          },
          name: "our loved one",
          note: "we miss them dearly",
          type: "memory"
        }
      }
      designation { "designated for soup kitchen" }

      nonprofit { association :fv_poverty }

      supporter { association :supporter }
      amount { 500 }
    end
  end
end
