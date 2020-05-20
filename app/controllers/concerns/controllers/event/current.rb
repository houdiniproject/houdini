# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::Event::Current
    extend ActiveSupport::Concern
    include Controllers::Nonprofit::Current

    included do
        private
        def current_event
            @event ||= FetchEvent.with_params params, current_nonprofit
            raise ActionController::RoutingError, 'Event not found' if @event.nil?

            @event
        end
    end
end