# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe ModernDonation, type: :model do
  it_behaves_like "trx assignable", :don
  it_behaves_like "an object with as_money attributes", :amount

  it {
    is_expected.to delegate_method(:designation).to(:legacy_donation)
  }

  it {
    is_expected.to delegate_method(:comment).to(:legacy_donation)
  }

  it {
    is_expected.to(belong_to(:legacy_donation)
      .class_name("Donation")
      .with_foreign_key("donation_id"))
  }

  describe "#dedication" do
    context "when legacy_donation has no dedication" do
      it {
        expect(ModernDonation.new(legacy_donation: Donation.new).dedication).to be_nil
      }
    end

    context "when legacy_donation has non-json parsable dedication" do
      it {
        expect(ModernDonation.new(legacy_donation: Donation.new(dedication: "Somest string")).dedication).to be_nil
      }
    end

    context "when legacy_donation has json parsable dedication" do
      it {
        input_json = {note: "My mom", type: "honor"}
        expect(ModernDonation.new(legacy_donation: Donation.new(dedication: input_json.to_json)).dedication).to include_json(**input_json)
      }
    end
  end
end
