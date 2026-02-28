# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe ".ccs" do
    describe "local_tar_gz" do
      before do
        Houdini.ccs = Houdini::Ccs.build("local_tar_gz")
      end

      it "fails on git archive" do
        expect(Kernel).to receive(:system).and_return(false)
        get("ccs")
        expect(response.status).to eq 500
      end
    end

    describe "github" do
      before do
        Houdini.ccs = Houdini::Ccs.build("github", account: "account", repo: "repo")
      end

      it "setup github" do
        expect(File).to receive(:read).with("#{Rails.root.join("CCS_HASH")}").and_return("hash\n")
        get("ccs")
        expect(response).to redirect_to "https://github.com/account/repo/tree/hash"
      end
    end
  end
end
