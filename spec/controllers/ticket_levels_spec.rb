# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe TicketLevelsController, type: :controller do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "create" do
        include_context :open_to_event_editor, :post, :create, nonprofit_id: :__our_np, event_id: :__our_event, id: "1"
      end

      describe "update" do
        include_context :open_to_event_editor, :put, :update, nonprofit_id: :__our_np, event_id: :__our_event, id: "1"
      end

      describe "update_order" do
        include_context :open_to_event_editor, :put, :update_order, nonprofit_id: :__our_np, event_id: :__our_event
      end

      describe "destroy" do
        include_context :open_to_event_editor, :delete, :destroy, nonprofit_id: :__our_np, event_id: :__our_event, id: "1"
      end
    end

    describe "open to all" do
      describe "show" do
        include_context :open_to_all, :get, :show, nonprofit_id: :__our_np, event_id: :__our_event, id: "2"
      end

      describe "index" do
        include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, event_id: :__our_event
      end
    end
  end

  describe "verify deleted doesnt get passed through on update" do
    include_context :shared_user_context
    include_context :shared_donation_charge_context
    let(:ticket_level_name) { "TICKET LEVEL" }
    let(:order) { 3 }
    let(:free_amount) { 0 }
    let(:non_free_amount) { 7500 }
    let(:ticket_limit) { 4 }
    let(:description) { "Description" }
    let(:ticket_level_2) {
      event.ticket_levels.create(
        name: ticket_level_name,
        limit: nil,
        admin_only: false,
        order: order,
        amount: non_free_amount,
        description: description
      )
    }

    it "updates safely" do
      input = {
        nonprofit_id: nonprofit.id,
        event_id: event.id,
        id: ticket_level_2.id,
        ticket_level: {
          name: ticket_level_name,
          limit: nil,
          admin_only: false,
          order: order,
          amount: 0,
          description: description,
          deleted: true
        }
      }
      sign_in user_as_np_admin
      put :update, params: input, xhr: true
      expect(response).to have_http_status :ok

      ticket_level_2.reload
      expect(ticket_level_2.deleted).to eq false
      expect(ticket_level_2.amount).to eq 0
    end
  end
end
