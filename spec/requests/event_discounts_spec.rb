# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe EventDiscountsController, type: :request do
  let(:event) { create(:event_base)}
  let(:nonprofit) { event.nonprofit }

  before(:each) do
    sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
    
  end

  describe "#create" do
    it 'returns the proper errors' do
    
      post nonprofit_event_event_discounts_path(event_id: event.id, nonprofit_id: nonprofit.id), 
          params: {event_discount: {invalid: "invalid"}}

      expect(JSON::parse(response.body)).to eq({"errors" => ["code required", "name required", "percent required"]})

      expect(response).to have_http_status(422)
    end
  end

  describe "#update" do
    it "works properly" do
      event_discount = create(:event_discount_base, event: event)

      put nonprofit_event_event_discount_path(event_id: event.id, nonprofit_id: nonprofit.id, id: event_discount.id),
           params: {event_discount: { code: 'a-new-code', percent: 80, name: "a New name"}, format: :json}
      expect(JSON::parse(response.body)).to eq({
        "id" => event_discount.id,
        "event_id" => event_discount.event_id,
        "name" => "a New name",
        "percent" => 80,
        "code" => "a-new-code"
      })
    end
  end
end