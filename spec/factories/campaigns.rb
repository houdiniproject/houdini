# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :campaign do
    profile
    nonprofit_id { 55352 }
    sequence(:name) { |i| "name #{i}" }
    sequence(:slug) { |i| "slug_#{i}" }
  end

  factory :fv_poverty_fighting_campaign, class: "Campaign" do
    name { "Fighting Poverty 2021" }
    goal_amount { 10000 }

    factory :fv_poverty_fighting_campaign_with_nonprofit_and_profile do
      nonprofit { create(:fv_poverty) }
      profile
    end
  end
end
