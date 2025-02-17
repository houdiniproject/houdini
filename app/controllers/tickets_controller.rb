# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketsController < ApplicationController
  include Controllers::Event::Current
  include Controllers::Event::Authorization

  helper_method :current_event_admin?, :current_event_editor?
  before_action :authenticate_event_editor!, except: %i[create add_note]
  before_action :authenticate_nonprofit_user!, only: [:delete_card_for_ticket]

  # post /nonprofits/:nonprofit_id/events/:event_id/tickets
  def create
    authenticate_event_editor! if params[:kind] == "offsite"
    render_json do
      params[:current_user] = current_user
      InsertTickets.create(params)
    end
  end

  def update
    ticket_params[:ticket_id] = params[:id]
    ticket_params[:event_id] = params[:event_id]
    render_json { UpdateTickets.update(ticket_params, current_user) }
  end

  # Attendees dashboard
  # get /nonprofits/:nonprofit_id/events/:event_id/tickets
  def index
    @panels_layout = true
    @nonprofit = current_nonprofit
    @event = current_event

    respond_to do |format|
      format.html
      format.csv do
        file_date = Date.today.strftime("%m-%d-%Y")
        filename = "tickets-#{file_date}"
        @tickets = QueryTickets.for_export(@event.id, params)
        send_data(Format::Csv.from_vectors(@tickets), filename: "#{filename}.csv")
      end

      format.json do
        render json: QueryTickets.attendees_list(@event.id, params)
      end
    end
  end

  # PUT nonprofits/:nonprofit_id/events/:event_id/tickets/:id/add_note
  def add_note
    current_nonprofit.tickets.find(params[:id]).update(note: ticket_params[:note])
    render json: {}
  end

  # DELETE nonprofits/:nonprofit_id/events/:event_id/tickets/:id
  def destroy
    UpdateTickets.delete(params[:event_id], params[:id])
    render json: {}
  end

  # POST nonprofits/:nonprofit_id/events/:event_id/tickets/:id/delete_card_for_ticket
  def delete_card_for_ticket
    @event = current_event
    render json: UpdateTickets.delete_card_for_ticket(@event.id, params[:id])
  end

  private

  def ticket_params
    params.require(:ticket).permit(:ticket_id, :event_id, :note, :event_discount, :event_discount_id)
  end
end
