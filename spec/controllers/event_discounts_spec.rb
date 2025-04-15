# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe EventDiscountsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'rejects unauthorized users' do
      describe 'create' do
        include_context :open_to_event_editor, :post, :create, nonprofit_id: :__our_np, event_id: :__our_event
      end

      describe 'update' do
        include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event, id: '2'
      end

      describe 'destroy' do
        include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event, id: '2'
      end
    end

    describe 'open to all' do
      describe 'index' do
        include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event, id: '2'
      end
    end
  end

  describe "methods" do
    let(:event) { create(:event_base)}
    let(:nonprofit) { event.nonprofit }
  
    before(:each) do
      sign_in create(:user_as_nonprofit_admin, nonprofit: nonprofit)
    end
  
    describe "#update" do
      it "works properly" do
        event_discount = create(:event_discount_base, event: event)

        patch :update, params: {
            event_discount: { code: 'a-new-code', percent: 80, name: "a New name"}, event_id: event.id, nonprofit_id: nonprofit.id, id: event_discount.id, format: :json
          }

        expect(assigns(:event_discount)).to eq event_discount
        
        event_discount.reload
        
        expect(event_discount.code).to eq 'a-new-code'
        
        expect(event_discount.percent).to eq 80

        expect(event_discount.name).to eq 'a New name'
      end
    end
  end
end