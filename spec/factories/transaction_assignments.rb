# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :transaction_assignment do
    assignable { build(:modern_donation) }
  end

  factory :transaction_assignment_base, class: "TransactionAssignment" do
    transient do
      legacy_donation { nil }
    end
    after(:build) do |instance, evaluator|
      instance.assignable = build(:modern_donation_base, legacy_donation: evaluator.legacy_donation)
    end
  end
end
