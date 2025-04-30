FactoryBot.define do
  factory :supporter_address do
    address { "MyString" }
    supporter
  end

  trait :with_empty_address do
    address { nil }
    city { nil }
    state_code { nil }
    zip_code { nil }
    country { nil }
  end

  trait :with_blank_address do
    address { "" }
    city { "" }
    state_code { "" }
    zip_code { "" }
    country { "" }
  end
  # we may need this is a set of places, like orders so let's just keep it here
  trait :with_custom_address_1 do
    address { "123 Address 1 Street" }
    city { "Appleton" }
    state_code { "WI" }
    zip_code { "54915" }
    country { "United States" }
  end
end
