FactoryBot.define do
  factory :fee_era do
    start_time { "2020-05-01" }
    end_time { "2020-05-07" }
    local_country { "US" }
    international_surcharge_fee { "0.01" }
    fee_coverage_detail_base
    factory :fee_era_with_structures, aliases: [:current_fee_era_with_structures], class: "FeeEra" do
      after(:create) do |fee_era|
        fee_era.fee_structures = [build(:visa_fee_structure_base),
          build(:amex_fee_structure_base),
          build(:brandless_fee_structure_base)]
        fee_era.save!
        fee_era.reload
      end
    end
  end

  factory :fee_era_with_no_start, class: "FeeEra" do
    end_time { "2020-05-01" }
    refund_stripe_fee { true }
    fee_coverage_detail_base
    after(:create) do |fee_era|
      fee_era.fee_structures.build(attributes_for(:brandless_fee_structure))
      fee_era.fee_coverage_detail_base = build(:fee_coverage_detail_base)
      fee_era.save!
      fee_era.reload
    end
  end

  factory :fee_era_with_no_end, aliases: [:fee_era_local_to_us], class: "FeeEra" do
    start_time { "2020-05-07" }
    local_country { "US" }
    international_surcharge_fee { "0.01" }
    fee_coverage_detail_base
    after(:create) do |fee_era|
      fee_era.fee_structures = [
        build(:amex_fee_structure_base),
        build(:brandless_fee_structure_base)
      ]
      fee_era.save!
      fee_era.reload
    end
  end

  factory :fee_era_base do
    fee_coverage_detail_base
    start_time { "2020-05-01" }
  end
end
