# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :payout do
    stripe_transfer_id { "tr_xxxxxxxxx" }
    email { Faker::Internet.email }
    net_amount { Faker::Number.number(digits: 5) }
  end
end
