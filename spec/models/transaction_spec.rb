# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Transaction, type: :model do
  include_context :shared_donation_charge_context

  describe "validation" do
    it { is_expected.to validate_presence_of(:supporter) }
  end

  describe "to_builder" do
    subject {
      supporter.transactions.create(
        amount: 1000,
        transaction_assignments: [TransactionAssignment.new(assignable: ModernDonation.new(amount: 1000))]
      ).to_builder.attributes!
    }

    it "will create a proper builder result" do
      is_expected.to match({
        "id" => match_houid("trx"),
        "nonprofit" => nonprofit.id,
        "supporter" => supporter.id,
        "object" => "transaction",
        "created" => Time.current.to_i,
        "amount" => {
          "cents" => 1000,
          "currency" => "usd"
        },
        "subtransaction" => nil,
        "payments" => [],
        "transaction_assignments" => [
          {
            "object" => "donation",
            "id" => match_houid("don"),
            "type" => "trx_assignment"
          }
        ]
      })
    end
  end
end
