# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do

  factory :payment, aliases: [:payment_base, :legacy_payment_base] do

    supporter {association :supporter_base}
    nonprofit {supporter.nonprofit}
    gross_amount { 333 }
    fee_total {0}
    net_amount { gross_amount + fee_total}
    
    trait :with_offline_payment do
      offsite_payment { association :offsite_payment_base, 
          nonprofit: nonprofit, 
          supporter: supporter,
          gross_amount: gross_amount,
          payment: @instance
        }
    end

    
    trait :with_offline_donation do 
      with_offline_payment 
      donation { build(:donation_base, supporter: supporter, payments: [@instance])}
    end
  end


  factory :donation_payment_generator, class: "Payment" do
    transient do
      amount { 100 + Random.rand(5000)}
    end
    
    donation { association :donation, amount: amount}
    gross_amount { amount}
    supporter
    date { Faker::Time.between(from: Time.current.beginning_of_year, to: Time.current.end_of_year)}
  end

  

  factory :fv_poverty_payment, class: "Payment" do
    donation {build(:fv_poverty_donation, nonprofit: nonprofit, supporter: supporter) }
    gross_amount { 333}
    net_amount { 333}
    nonprofit { association :fv_poverty}
    supporter { build(:supporter_with_fv_poverty, nonprofit: nonprofit)}

    trait :anonymous_through_donation do 
       donation {build(:fv_poverty_donation, nonprofit: nonprofit, supporter: supporter, anonymous:true) }
    end

    trait :anonymous_through_supporter do 
      supporter {build(:supporter_with_fv_poverty, nonprofit: nonprofit, anonymous: true) }
   end
  end
end
