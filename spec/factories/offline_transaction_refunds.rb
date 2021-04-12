# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
FactoryBot.define do
  factory :offline_transaction_refund do
    payment { "" }
    created { "2021-04-12 17:24:33" }
  end
end
