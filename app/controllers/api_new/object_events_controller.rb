# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module ApiNew
  class ObjectEventsController < ApiNew::ApiController
    include Controllers::ApiNew::Nonprofit::Current
    include Controllers::Nonprofit::Authorization
    before_action :authenticate_nonprofit_user!

    has_scope :event_entity
    has_scope :event_types, type: :array

    # Gets the nonprofits object events
    # If not logged in, causes a 401 error
    def index
      @object_events = apply_scopes(current_nonprofit
        .associated_object_events)
        .order("created_at DESC").page(params[:page]).per(params[:per])
    end
  end
end
