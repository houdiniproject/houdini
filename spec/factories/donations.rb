# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :donation do
    
  end

  factory :fv_poverty_donation, class: 'Donation' do
    nonprofit {association  :fv_poverty}

    supporter { build(:supporter_with_fv_poverty, nonprofit: nonprofit)}
    amount  {333}
    factory :donation_with_dedication_designation do 
      dedication { {
        contact: {
          email: 'email@ema.com'
        },
        name: 'our loved one',
        note: "we miss them dearly",
        type: 'memory'
      } }
      designation { 'designated for soup kitchen'}

      nonprofit {association  :fv_poverty}

      supporter { association  :supporter}
      amount  {500}
    end
  end  
end
