# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketLevelsController < ApplicationController
  include Controllers::Event::Current
  include Controllers::Event::Authorization

  before_action :authenticate_event_editor!, except: %i[index show]

  def index
    event_id = current_event.id
    render json: {data: QueryTicketLevels.with_event_id(event_id, current_role?(:event_editor, event_id) || current_role?(:super_admin) || current_role?(:nonprofit_admin, current_event.nonprofit_id))}
  end

  def show
    render json: current_ticket_level
  end

  def create
    ticket_level = current_event.ticket_levels.create ticket_level_params
    json_saved ticket_level, "Ticket level created!"
  end

  def update
    current_ticket_level.update ticket_level_params
    json_saved current_ticket_level, "Ticket level updated"
  end

  # put /nonprofits/:nonprofit_id/events/:event_id/ticket_levels/update_order
  # Pass in {data: [{id: 1, order: 1}]}
  def update_order
    updated_ticket_levels = UpdateOrder.with_data("ticket_levels", params[:data])
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

  def ticket_level_params
    params.require(:ticket_level).permit(:amount, :amount_dollars, :name, :description, :quantity, :event_id, :admin_only, :limit, :order)
  end
end
