# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :campaign_gift_option, aliases: [:campaign_gift_option_base] do
    sequence(:name) { |i| "name_#{i}" }
    campaign { build(:campaign_with_things_set_1) }
    amount_one_time { 200 }

    trait :with_one_campaign_gift do
      campaign_gifts {
        [
          build(:campaign_gift,
            donation: build(:donation_base_with_supporter, campaign: campaign, nonprofit: campaign.nonprofit))
        ]
      }
    end

    trait :with_two_campaign_gifts do
      campaign_gifts {
        build_list(:campaign_gift, 2, donation: build(:donation_base_with_supporter, campaign: campaign, nonprofit: campaign.nonprofit))
      }
    end
  end
end
