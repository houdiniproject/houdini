# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe FetchNonprofitEmail, pending: true do
  context ".with_charge" do
    let(:charge) { Models::Charge }

    it "returns the nonprofit org email if it's there!" do
      charge.nonprofit.email = "nonprofit@someorg.org"
      expect(FetchNonprofitEmail.with_charge(charge)).to eq("nonprofit@someorg.org")
    end

    it "returns support@commitchange.com if Nonprofit email is blank" do
      charge.nonprofit.email = ""
      expect(FetchNonprofitEmail.with_charge(charge)).to eq("support@commitchange.com")
    end

    it "returns support@commitchange.com if Nonprofit email is nil" do
      charge.nonprofit.email = nil
      expect(FetchNonprofitEmail.with_charge(charge)).to eq("support@commitchange.com")
    end
  end
end
