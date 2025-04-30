# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.id object_event.houid
json.created object_event.created.to_i
json.object "object_event"
json.type object_event.event_type
json.data do
  json.object do
    json.partial! partial_path, event_entity: object_event.event_entity
  end
end
