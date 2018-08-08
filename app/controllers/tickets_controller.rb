# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TicketsController < ApplicationController
	include Controllers::EventHelper

	helper_method :current_event_admin?, :current_event_editor?
	before_filter :authenticate_event_editor!, :except => [:create, :add_note]
  before_filter :authenticate_nonprofit_user!, only: [:delete_card_for_ticket]

	# post /nonprofits/:nonprofit_id/events/:event_id/tickets
	def create
    authenticate_event_editor! if params[:kind] == 'offsite'
    render_json do
      params[:current_user] = current_user
      InsertTickets.create(params)
    end
  end

  def update
    params[:ticket][:ticket_id] = params[:id]
    params[:ticket][:event_id] = params[:event_id]
    render_json{ UpdateTickets.update(params[:ticket], current_user) }
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
    current_nonprofit.tickets.find(params[:id]).update_attributes(note: params[:ticket][:note])
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
end
