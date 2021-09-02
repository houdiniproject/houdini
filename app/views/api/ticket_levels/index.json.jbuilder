# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.array! @ticket_levels, partial: '/api/ticket_levels/ticket_level', as: 'ticket_level'
