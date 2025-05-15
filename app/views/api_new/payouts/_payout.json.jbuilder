# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.id payout.houid

json.object "payout"

json.created payout.created_at.to_i

json.net_amount do
  json.partial! "/api_new/common/amount", amount: payout.net_amount_as_money
end

json.status payout.status
