# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a nonprofit's supporters
class Api::TicketLevelsController < Api::ApiController
  include Controllers::Event::Current
  include Controllers::Event::Authorization

  before_action :authenticate_event_editor!

  def index
    @ticket_levels =
      current_event
        .ticket_levels
        .order("id DESC")
        .page(params[:page])
        .per(params[:per])
  end

  # Gets the single event ticket
  # If not logged in, causes a 401 error
  def show
    @ticket_level = current_event.ticket_levels.find(params[:id])
  end
end
