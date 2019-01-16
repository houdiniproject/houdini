# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :card do

      factory :active_card_1 do
        name { 'card 1' }
      end
      factory :active_card_2 do
        name { 'card 1' }
      end
      factory :inactive_card do
        name { 'card 1' }
        inactive { true }
      end



  end
end
