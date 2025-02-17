# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(event, :id, :name)

json.object "event"

json.url api_nonprofit_event_url(event.nonprofit, event)

json.nonprofit event.nonprofit.id
