# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventPublisher
    include Wisper::Publisher

    def announce(event, *args)
        broadcast(event, *args)
    end

    def subscribe_async(listener, options = {})
        subscribe(listener, options.merge(async: true))
    end
end