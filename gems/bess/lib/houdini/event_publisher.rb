# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'wisper'
require 'wisper/activejob'
class Houdini::EventPublisher
    include Wisper::Publisher

    def announce(event, *args)
        broadcast(event, *args)
    end

    def subscribe_async(listener, options = {})
        subscribe(listener, options.merge(async: true))
    end

    def subscribe_all(listeners, options = {})
        listeners.each do |listener|
            subscribe(listener, options.merge(async: true))
        end
    end
end