# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :subtransaction do
    subtransactable { create(:offline_transaction) }
    payments do
      [
        create(:subtransaction_payment_with_offline_charge)
      ]
    end
  end
end
