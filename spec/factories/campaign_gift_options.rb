# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :campaign_gift_option do
    sequence(:name) {|i| "name_#{i}"}
    campaign
    amount_one_time { 200 }
  end
end
