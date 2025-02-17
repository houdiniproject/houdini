# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe Api::ApiController do
  it {
    is_expected.to rescue_from(AuthenticationError).with(:unauthorized_rescue)
  }

  describe "rescues" do
    render_views
    describe "AuthenticationError" do
      controller(described_class) do
        def index
          raise AuthenticationError
        end
      end

      before { get :index, format: :json }

      it {
        expect(response).to have_http_status(:unauthorized)
      }

      context "with result body" do
        subject(:body) { response.parsed_body }

        it {
          is_expected.to match_json(message: "AuthenticationError")
        }
      end
    end
  end
end
