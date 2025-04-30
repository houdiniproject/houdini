FactoryBot.define do
  factory :visa_fee_structure_base, class: "FeeStructure" do
    flat_fee { 25 }
    stripe_fee { BigDecimal("0.03") }
    brand { "Visa" }
  end

  factory :visa_fee_structure, aliases: [:countryless_fee_structure], parent: :visa_fee_structure_base do
    association :fee_era

    factory :local_to_us_visa_fee_structure, aliases: [:us_local_fee_structure] do
      fee_era { association :fee_era_local_to_us }
    end
  end

  factory :amex_fee_structure_base, class: "FeeStructure" do
    flat_fee { 0 }
    stripe_fee { BigDecimal("0.035") }
    brand { "American Express" }
  end

  factory :amex_fee_structure, parent: :amex_fee_structure_base do
    association :fee_era

    factory :local_to_us_amex_fee_structure do
      fee_era { association :fee_era_local_to_us }
    end
  end

  factory :brandless_fee_structure_base, class: "FeeStructure" do
    flat_fee { 30 }
    stripe_fee { BigDecimal("0.022") }
    brand { nil }
  end

  factory :brandless_fee_structure, parent: :brandless_fee_structure_base do
    association :fee_era

    factory :no_international_fees_brandless_fee_structure do
      fee_era { association :fee_era_with_no_start }
    end
  end
end
