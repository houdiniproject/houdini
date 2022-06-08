
FactoryBot.define do
  
  factory :payment_expectation, class: "OpenStruct" do
    transient do
      gross_amount_cents { 500 }
      currency { 'usd'}
      fee_total_cents { 0}
    end
    

    transaction {match_houid(:trx)}
    nonprofit {match_houid(:np)}
    supporter { match_houid(:supp)}

    type {'payment'}
    created { Time.current.to_i }
    gross_amount { {cents: gross_amount_cents, currency:currency}}
    fee_total { {cents: fee_total_cents, currency: currency} }
    net_amount { {cents: gross_amount_cents + fee_total_cents, currency: currency}}

    trait :offline_transaction_charge do 
      object { 'offline_transaction_charge'}
      id { match_houid(:offtrxchrg)}
      subtransaction { match_houid(:offlinetrx)}
    end

    trait :stripe_transaction_charge do 
      object { 'stripe_transaction_charge'}
      id { match_houid(:stripechrg)}
      subtransaction { match_houid(:stripetrx)}
    end
  end
end