FactoryBot.define do
  factory :fee_coverage_detail_base do
    flat_fee { 30 }
    percentage_fee { "0.022" }
  end

  factory :dont_consider_billing_plan_fee_coverage_detail_base, class: "FeeCoverageDetailBase" do
    flat_fee { 0 }
    percentage_fee { "0.05" }
    dont_consider_billing_plan { true }
  end
end
