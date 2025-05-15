# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :trx, class: "OpenStruct" do
    transient do
      amount_cents { 500 }
      currency { "usd" }
    end

    nonprofit { match_houid(:np) }
    id { match_houid(:trx) }
    supporter { match_houid(:supp) }
    # created { Time.current.to_i }
    amount { {cents: amount_cents, currency: currency} }
    object { "transaction" }

    trait :concrete do
      # a set of properties that don't do matching but make this a concrete example
      nonprofit { "np_JMR7tipP7swuk0Kxk2RBss" }
      id { "trx_gSxbMtyNaDnQKgwF1kzzit" }
      supporter { "supp_8SE0GLbbsJWJ5jOpACG4Fu" }
    end
  end
end
