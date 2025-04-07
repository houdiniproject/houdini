# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a nonprofit's supporters
class Api::EventsController < Api::ApiController
  include Controllers::Event::Current
  include Controllers::Event::Authorization

  before_action :authenticate_event_editor!, only: :show

  # Gets the a single nonprofit campaign
  # If not logged in, causes a 401 error
  def show
    @event = current_event
  end
end
