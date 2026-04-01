# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TicketsController < ApplicationController
  include Controllers::EventHelper

  helper_method :current_event_admin?, :current_event_editor?
  before_action :authenticate_event_editor!, except: [:create, :add_note]
  before_action :authenticate_nonprofit_user!, only: [:delete_card_for_ticket]
  before_action :authenticate_ticket_editor!, only: [:add_note]

  # post /nonprofits/:nonprofit_id/events/:event_id/tickets
  def create
    authenticate_event_editor! if params[:kind] == "offsite"
    render_json do
      params[:current_user] = current_user
      result = InsertTickets.create(params)
      session[:purchased_ticket_ids] ||= []
      session[:purchased_ticket_ids] += result["tickets"].map(&:id)
      result
    end
  end

  def update
    params[:ticket][:ticket_id] = params[:id]
    params[:ticket][:event_id] = params[:event_id]
    render_json { UpdateTickets.update(params[:ticket], current_user) }
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
        file_date = Time.zone.today.to_fs(:mdy)
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
    current_nonprofit.tickets.find(params[:id]).update(note: params[:ticket][:note])
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

  def authenticate_ticket_editor!
    purchased_ids = session[:purchased_ticket_ids] || []
    ticket_id = params[:id].to_i
    return if purchased_ids.include?(ticket_id)
    return if current_event_editor?

    raise AuthenticationError
  end
end
