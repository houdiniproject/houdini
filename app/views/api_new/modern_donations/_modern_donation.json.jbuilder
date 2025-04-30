# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.object "donation"

json.call(assignable, :designation, :legacy_id, :dedication, :comment)

json.amount do
  json.partial! "/api_new/common/amount", amount: assignable.amount_as_money
end
