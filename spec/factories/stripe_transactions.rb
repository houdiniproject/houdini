# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :stripe_transaction do
    amount { 4000 }
    factory :stripe_transaction_for_testing_payment_extensions do
      transient do
        currency { "fake" }
      end

      amount { 707 }

      subtransaction { build(:subtransaction_for_testing_payment_extensions) }
    end
  end
end
