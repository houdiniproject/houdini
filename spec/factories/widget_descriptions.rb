FactoryBot.define do
  factory :widget_description do
    houid { "wdgtdesc_ienth1" }
    custom_recurring_donation_phrase { "current donation" }
    custom_amounts { {} }
    postfix_element { {} }
  end
end
