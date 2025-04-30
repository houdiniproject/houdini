# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :offsite_payment do
  end
  factory :offsite_payment_base, class: "OffsitePayment" do
    payment { association :legacy_payment_base, :with_offline_donation, offsite_payment: @instance }
    supporter { association :supporter_base }
    nonprofit { supporter.nonprofit }
  end
end
