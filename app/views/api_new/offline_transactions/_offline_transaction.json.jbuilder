# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.object "offline_transaction"

json.created subtransactable.created.to_i

json.amount do
  json.partial! "/api_new/common/amount", amount: subtransactable.amount_as_money
end

json.net_amount do
  json.partial! "/api_new/common/amount", amount: subtransactable.net_amount_as_money
end
