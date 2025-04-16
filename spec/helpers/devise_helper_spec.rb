# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe DeviseHelper, type: :helper do
  describe "#devise_error_messages!" do
    let(:valid_user) { build(:user_base)}
    let(:invalid_user) { build(:user_base, email: "invaliduser", password: "not the same as", password_confirmation: "confirmation")}
    
    it "returns nil when no error" do
      assign(:resource, valid_user)
      valid_user.save
      expect(helper.devise_error_messages!).to eq nil
    end

    it "returns something when errored" do
      assign(:resource, invalid_user)
      invalid_user.save
      expect(helper.devise_error_messages!).to eq "Email is invalid"
    end
  end
end
