# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :offline_transaction_charge do
    payment { create(:payment, gross_amount: 4000, net_amount: 3700, fee_total: 300, date: Time.current) }
  end
end
