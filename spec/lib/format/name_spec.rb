# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Format::Name do
  describe ".email_from_np" do
    it "gives the name, minus commas, with our email in brackets" do
      result = Format::Name.email_from_np("Test, X, Y")
      expect(result).to eq("\"Test X Y\" <support@commitchange.com>")
    end
  end
end
