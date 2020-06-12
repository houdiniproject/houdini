# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
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