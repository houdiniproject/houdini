# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe ModernDonation, type: :model do
  include_context :shared_donation_charge_context
  # TODO Why are we manually setting everything here? It's not clear what order things should
  # go in for a transaction. Therefore, we don't assume the order for now and just make sure the
  # the output of to_builder is right
  let(:trx) { force_create(:transaction, supporter: supporter, amount: 1200) }
  let(:legacy_donation) { force_create(:donation, amount: 1200) }
  let(:dedication) {
    {
      type: "honor",
      name: "Grandma Schultz"
    }
  }

  let(:legacy_donation_with_dedication_and_designation) { force_create(:donation, amount: 1200, designation: "designation", dedication: dedication) }

  describe "to_builder" do
    let(:don_default) do
      {
        "id" => match_houid("don"),
        "object" => "donation",
        "nonprofit" => nonprofit.id,
        "supporter" => supporter.id,
        "amount" => {"currency" => "usd", "cents" => 1200},
        "transaction" => trx.id,
        "designation" => nil,
        "type" => "trx_assignment"
      }
    end

    it "without dedication or designation" do
      donation = trx.donations.create(amount: 1200)
      donation.legacy_donation = legacy_donation
      donation.save!
      expect(donation.to_builder.attributes!).to match(don_default)
    end

    it "with designation and dedication" do
      donation = trx.donations.create(amount: 1200)
      donation.legacy_donation = legacy_donation_with_dedication_and_designation
      donation.save!

      expect(donation.to_builder.attributes!).to match(don_default.merge({
        "designation" => "designation",
        "dedication" => {
          "type" => "honor",
          "name" => "Grandma Schultz"
        }
      }))
    end
  end
end
