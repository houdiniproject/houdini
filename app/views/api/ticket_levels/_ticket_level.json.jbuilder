# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(ticket_level, :id, :name, :name, :deleted, :order, :limit, :description)

json.object "ticket_level"

json.amount do
  json.partial! "/api/common/amount", amount: ticket_level.amount_as_money
end

json.available_to ticket_level.admin_only ? "admins" : "everyone"

json.url api_nonprofit_event_ticket_level_url(ticket_level.nonprofit, ticket_level.event, ticket_level)

json.nonprofit ticket_level.nonprofit.id
json.event ticket_level.event.id

json.event_discounts ticket_level.event_discounts.pluck(:id)
