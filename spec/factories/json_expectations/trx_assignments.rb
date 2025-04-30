# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :trx_assignment_expectation, class: "OpenStruct" do
    transient do
      amount_cents { 500 }
      currency { "usd" }
    end

    transaction { match_houid(:trx) }
    nonprofit { match_houid(:np) }
    supporter { match_houid(:supp) }

    type { "trx_assignment" }
    amount { {cents: amount_cents, currency: currency} }

    trait :donation do
      id { match_houid(:don) }
      object { "donation" }
    end
  end
end
