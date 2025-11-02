# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :payout do
    stripe_transfer_id { "po_xxxxxxxxx" }
    email { Faker::Internet.email }
    net_amount { Faker::Number.number(digits: 5) }
    nonprofit

    trait :old_transfer_type do
      stripe_transfer_id { "tr_xxxxxxx" }
    end
  end
end
