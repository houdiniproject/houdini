FactoryBot.define do
  factory :stripe_transaction_charge do
    transient do
      gross_amount { 4000 }
      fee_total { -300 }
      net_amount { gross_amount - fee_total }
      supporter { create(:supporter_with_fv_poverty) }
      nonprofit { supporter.nonprofit }
    end
  end
end
