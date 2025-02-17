# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe DirectDebitDetailsController, type: :request do
  describe "POST /sepa" do
    let!(:nonprofit) { Nonprofit.create(name: "new", city: "NY", state_code: "NY") }
    let(:supporter) { Supporter.create(nonprofit: nonprofit) }

    let(:valid_params) do
      {
        supporter_id: supporter.id,
        sepa_params: {
          iban: "iban",
          bic: "bic",
          name: "name"
        }
      }
    end

    describe "requires params" do
      it "is valid when sepa_params, donation_id and supporter_id are present" do
        post "/sepa", params: valid_params

        assert_response 200
        assert_nil JSON.parse(@response.body)["errors"]
      end

      it "is not valid without sepa_params" do
        post "/sepa", params: valid_params.except(:sepa_params)

        assert_response 422
        assert_equal ["sepa_params required"], JSON.parse(@response.body)["errors"]
      end

      it "is not valid without supporter_id" do
        post "/sepa", params: valid_params.except(:supporter_id)

        assert_response 422
        assert_equal ["supporter_id required"], JSON.parse(@response.body)["errors"]
      end
    end
  end
end
