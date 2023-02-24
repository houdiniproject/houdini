# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :payout do
    nonprofit
    net_amount { 10000 }
    stripe_transfer_id { "tr_3532o5nfcih"}
    email { "email@email.com"}
  end
end
