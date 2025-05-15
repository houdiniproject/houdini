# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe CardsController, type: :request do
  describe "throttling" do
    before(:each) do
      stub_const("FORCE_THROTTLE", true)
    end
    let!(:supporter) { create(:supporter_base) }
    it "test number of card throttle" do
      6.times {
        post "/cards", params: {card: {holder_type: "Supporter", holder_id: supporter.id}}.to_json, headers: {"CONTENT_TYPE" => "application/json"}
      }

      expect(response.status.to_s).to start_with "4"

      Timecop.freeze(61) do
        post "/cards", params: {card: {holder_type: "Supporter", holder_id: supporter.id}}.to_json, headers: {"CONTENT_TYPE" => "application/json"}
        expect(@response.status).to_not eq 429
      end
    end
  end
end
