# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe Nonprofits::SupportersController, type: :request do


  describe 'throttling' do
    before(:each) do
      stub_const('FORCE_THROTTLE', true)
    end
    it 'test number of supporter throttle' do
      11.times {
         post '/nonprofits/1/supporters',  {email: 'email@i.com'}.to_json, {"CONTENT_TYPE" => "application/json" }

      }

      assert_response 429

      Timecop.freeze(61) do
        post '/nonprofits/1/supporters',  {email: 'email@i.com'}.to_json, {"CONTENT_TYPE" => "application/json" }
        expect(@response.status).to_not eq 429
      end

    end
  end
  describe 'POST /sepa' do
    let!(:nonprofit) { Nonprofit.create(name: "new", city: "NY", state_code: "NY") }
    let(:supporter) { Supporter.create(nonprofit: nonprofit) }

    let(:valid_params) do {
        supporter_id: supporter.id,
        sepa_params: {
          iban: "iban",
          bic: "bic",
          name: "name"
        }
      }
    end

    describe 'requires params' do
      it 'is valid when sepa_params, donation_id and supporter_id are present' do
        post "/sepa", valid_params

        assert_response 200
        assert_equal nil, JSON.parse(@response.body)["errors"]
      end

      it 'is not valid without sepa_params' do
        post "/sepa", valid_params.except(:sepa_params)

        assert_response 422
        assert_equal ["sepa_params required"], JSON.parse(@response.body)["errors"]
      end

      it 'is not valid without supporter_id' do
        post "/sepa", valid_params.except(:supporter_id)

        assert_response 422
        assert_equal ["supporter_id required"], JSON.parse(@response.body)["errors"]
      end
    end
  end
end
