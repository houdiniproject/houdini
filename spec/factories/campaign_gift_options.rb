FactoryBot.define do
  factory :campaign_gift_option do
    sequence(:name) {|i| "name_#{i}"}
    campaign
    amount_one_time 200
  end
end
