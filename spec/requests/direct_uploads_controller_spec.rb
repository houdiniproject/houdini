# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe DirectUploadsController do
  describe "POST /rails/active_storage/direct_uploads" do
    context "when not logged in" do
      it {
        expect { post "/rails/active_storage/direct_uploads.json" }.to raise_error(AuthenticationError)
      }
    end

    context "when logged in but not confirmed" do
      before do
        sign_in create(:user)
      end

      it {
        expect { post "/rails/active_storage/direct_uploads.json" }.to raise_error(AuthenticationError)
      }
    end

    context "when logged in but confirmed" do
      before do
        sign_in create(:confirmed_user)
      end

      it {
        expect { post "/rails/active_storage/direct_uploads.json" }.to_not raise_error(AuthenticationError)
      }
    end
  end
end
