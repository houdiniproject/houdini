# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe ".ccs" do
    around(:each) do |example|
      example.run
      Settings.reload!
    end

    describe "local_tar_gz" do
      before(:each) do
        Settings.merge!(
          {
            ccs: {
              ccs_method: "local_tar_gz"
            }
          }
        )
      end

      it "fails on git archive" do
        expect(Kernel).to receive(:system).and_return(false)
        get("ccs")
        expect(response.status).to eq 500
      end
    end

    it "setup github" do
      Settings.merge!(
        {
          ccs: {
            ccs_method: "github",
            options: {
              account: "account",
              repo: "repo"
            }
          }
        }
      )
      expect(File).to receive(:read).with("#{Rails.root.join("CCS_HASH")}").and_return("hash\n")
      get("ccs")
      expect(response).to redirect_to "https://github.com/account/repo/tree/hash"
    end
  end
end
