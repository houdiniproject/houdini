# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :transaction do
    supporter { create(:supporter) }
  end

  factory :transaction_for_donation, class: "Transaction" do
    amount { 4000 }
    supporter { create(:supporter_with_fv_poverty) }
    subtransaction {
      build(
        :subtransaction
      )
    }

    transaction_assignments {
      [
        build(:transaction_assignment)
      ]
    }
  end
end
