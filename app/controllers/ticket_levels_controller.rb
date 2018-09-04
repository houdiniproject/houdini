# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TicketLevelsController < ApplicationController
	include Controllers::EventHelper

	before_filter :authenticate_event_editor!, :except => [:index, :show]

	def index
    ev_id = current_event.id
    render json: {data: QueryTicketLevels.with_event_id(ev_id, current_role?(:event_editor, ev_id) || current_role?(:super_admin) || current_role?(:nonprofit_admin, current_event.nonprofit_id))}
	end

	def show
		render json: current_ticket_level
	end

	def create
		ticket_level = current_event.ticket_levels.create params[:ticket_level]
		json_saved ticket_level, 'Ticket level created!'
	end

	def update
		current_ticket_level.update_attributes params[:ticket_level]
		json_saved current_ticket_level, 'Ticket level updated'
	end

  # put /nonprofits/:nonprofit_id/events/:event_id/ticket_levels/update_order
  # Pass in {data: [{id: 1, order: 1}]}
  def update_order
    updated_ticket_levels = UpdateOrder.with_data('ticket_levels', params[:data])
    render json: updated_ticket_levels
  end

  def destroy
		current_ticket_level.destroy
		render json: {}
	end

private

	def current_ticket_level
		@ticket_level ||= current_event.ticket_levels.find params[:id]
	end

end
