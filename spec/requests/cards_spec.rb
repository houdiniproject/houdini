# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CardsController, type: :request do


  describe 'throttling' do
    before(:each) do
      FORCE_THROTTLE = true
    end
    it 'test number of card throttle' do
      4.times {
         post '/cards',  {card:{holder_type:'Supporter', holder_id: 1}}.to_json, {"CONTENT_TYPE" => "application/json" }

      }

      assert_response 429

      Timecop.freeze(61) do
        post '/nonprofits/1/supporters',  {card:{holder_type:'Supporter', holder_id: 1}}.to_json, {"CONTENT_TYPE" => "application/json" }
        expect(@response.status).to_not eq 429
      end

    end
  end
end

