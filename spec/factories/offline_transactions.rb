# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :offline_transaction do
    amount { 4000 }
  end

  factory :offline_transaction_for_testing_payment_extensions, class: "OfflineTransaction" do
    transient do
      currency { "fake" }
    end

    amount { 707 }

    subtransaction { build(:subtransaction_for_testing_payment_extensions) }
  end

  factory :offline_transaction_base, class: "OfflineTransaction" do
    amount { 333 }
  end
end
