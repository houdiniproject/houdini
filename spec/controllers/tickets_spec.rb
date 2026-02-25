# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
require "controllers/support/shared_user_context"

describe TicketsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "update" do
        include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event, id: 1111
      end
      describe "index" do
        include_context :open_to_event_editor, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event, without_json_view: true
      end

      describe "destroy" do
        include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event, id: 1111
      end

      describe "delete_card_for_ticket" do
        include_context :open_to_np_associate, :post, :delete_card_for_ticket, nonprofit_id: :__our_np, event_id: :__our_event, id: 11_111
      end
    end

    describe "open to all" do
      describe "create" do
        include_context :open_to_all, :post, :create, nonprofit_id: :__our_np, event_id: :__our_event
      end
    end
  end

  describe "add_note authorization" do
    include_context :shared_user_context

    let(:event) { create(:event, nonprofit: nonprofit) }
    let(:supporter) { create(:supporter, nonprofit: nonprofit) }
    let(:ticket) { create(:ticket, event: event, supporter: supporter) }

    it "allows event editor to add note" do
      sign_in user_as_np_admin
      expect_any_instance_of(TicketsController).to receive(:add_note).and_call_original
      put :add_note, params: {nonprofit_id: nonprofit.id,
                              event_id: event.id,
                              id: ticket.id,
                              ticket: {note: "test note"}}
      expect(response).to have_http_status(:ok)
    end

    it "allows ticket purchaser to add note via session" do
      session[:purchased_ticket_ids] = [ticket.id]
      put :add_note, params: {nonprofit_id: nonprofit.id,
                              event_id: event.id,
                              id: ticket.id,
                              ticket: {note: "test note"}}
      expect(response).to have_http_status(:ok)
    end

    it "rejects unauthenticated user without session" do
      expect do
        put :add_note, params: {nonprofit_id: nonprofit.id,
                                event_id: event.id,
                                id: ticket.id,
                                ticket: {note: "test note"}}
      end.to raise_error(AuthenticationError)
    end

    it "rejects user with different ticket in session" do
      session[:purchased_ticket_ids] = [ticket.id + 999]
      expect do
        put :add_note, params: {nonprofit_id: nonprofit.id,
                                event_id: event.id,
                                id: ticket.id,
                                ticket: {note: "test note"}}
      end.to raise_error(AuthenticationError)
    end
  end
end
