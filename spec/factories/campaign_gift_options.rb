# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :campaign_gift_option do
    sequence(:name) { |i| "name_#{i}" }
    campaign
    amount_one_time { 200 }
  end

  factory :campaign_gift_option_with_campaign, class: "CampaignGiftOption" do
    campaign { create(:fv_poverty_fighting_campaign_with_nonprofit_and_profile) }
    factory :campaign_gift_option_with_campaign_with_one_time_amount do
      name { "has one time amount" }
      description { "one time description" }
      amount_one_time { 200 }
    end

    factory :campaign_gift_option_with_campaign_with_recurring_amount do
      name { "has recurring amount" }
      description { "a recurring description!" }
      amount_recurring { 400 }
      quantity { 4 }
    end

    factory :campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount do
      name { "has both one time and recurring amount" }
      description { "one time AND recurring" }
      amount_one_time { 300 }
      amount_recurring { 500 }
      quantity { 50 }
      to_ship { true }
      order { 5 }
      hide_contributions { true }
    end
  end
end
