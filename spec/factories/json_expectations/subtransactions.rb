FactoryBot.define do
  factory :subtransaction_expectation, class: "OpenStruct" do
    transient do
      gross_amount_cents { 500 }
      currency { "usd" }
      net_amount_cents { 500 }
    end

    transaction { match_houid(:trx) }
    nonprofit { match_houid(:np) }
    supporter { match_houid(:supp) }

    type { "subtransaction" }
    created { Time.current.to_i }
    amount { {cents: gross_amount_cents, currency: currency} }
    net_amount { {cents: net_amount_cents, currency: currency} }

    trait :offline_transaction do
      object { "offline_transaction" }
      id { match_houid(:offlinetrx) }
      payments { [match_houid(:offtrxchrg)] }
    end

    trait :stripe_transaction do
      object { "stripe_transaction" }
      id { match_houid(:stripetrx) }
      payments { [match_houid(:stripechrg)] }
    end
  end
end
