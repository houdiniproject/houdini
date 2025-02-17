# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :subtransaction_payment do
    factory :subtransaction_payment_with_offline_charge do
      paymentable { create(:offline_transaction_charge) }
    end
  end
end
