# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe EventDiscountsController, type: :request do
  let(:event) { create(:event_base)}
  let(:nonprofit) { event.nonprofit }
  let(:event_discount) { create(:event_discount_base, event: event) }

  before(:each) do
    sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
    
  end

  describe "#create" do
    it 'returns the proper errors' do
      expect do
        post nonprofit_event_event_discounts_path(event_id: event.id, nonprofit_id: nonprofit.id), 
            params: {event_discount: {invalid: "invalid"}, format: :json}
      end.not_to change {event.event_discounts.count}

      expect(JSON::parse(response.body)).to eq({"errors" => {"code"=>["can't be blank"], "name"=>["can't be blank"], "percent"=>["can't be blank", "is not a number"]}})

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'creates an event discount_properly' do
    
      expect do
        post nonprofit_event_event_discounts_path(event_id: event.id, nonprofit_id: nonprofit.id), 
            params: {event_discount: { code: 'a-new-code', percent: 80, name: "a New name"}, format: :json}
      end.to change { event.event_discounts.count }.by(1)

      event_discount = EventDiscount.last

      expect(JSON::parse(response.body)).to eq(event_discount.attributes.slice('code', 'event_id', 'id', 'name', 'percent'))
      
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    
    it 'returns the proper errors' do
      put nonprofit_event_event_discount_path(event_id: event.id, nonprofit_id: nonprofit.id, id: event_discount.id), 
          params: {event_discount: {code: "", name: "", percent: ""}, format: :json}

      expect(JSON::parse(response.body)).to eq({"errors" => {"code"=>["can't be blank"], "name"=>["can't be blank"], "percent"=>["can't be blank", "is not a number"]}})

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "works properly" do
      put nonprofit_event_event_discount_path(event_id: event.id, nonprofit_id: nonprofit.id, id: event_discount.id),
           params: {event_discount: { code: 'a-new-code', percent: 80, name: "a New name"}, format: :json}
      expect(JSON::parse(response.body)).to eq({
        "id" => event_discount.id,
        "event_id" => event_discount.event_id,
        "name" => "a New name",
        "percent" => 80,
        "code" => "a-new-code"
      })

      expect(response).to have_http_status(:ok)

      event_discount.reload

      expect(event_discount.attributes.slice("name", "percent", "code")).to eq( 
        "name" => "a New name",
        "percent" => 80,
        "code" => "a-new-code"
      )
    end
  end
end