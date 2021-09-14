# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :payment do
    
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
