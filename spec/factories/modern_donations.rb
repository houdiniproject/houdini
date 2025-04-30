# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :modern_donation do
    amount { 4000 }
  end

  factory :modern_donation_base, class: "ModernDonation" do
    amount {
      legacy_donation.payments.first.gross_amount
    }
  end
end
