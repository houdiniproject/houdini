# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.id subtransaction.to_houid
json.type "subtransaction"

json.created subtransaction.created.to_i

handle_expansion(:supporter, subtransaction.supporter, {json: json, __expand: __expand})
handle_expansion(:nonprofit, subtransaction.nonprofit, {json: json, __expand: __expand})
handle_expansion(:transaction, subtransaction.trx, {json: json, __expand: __expand})

handle_array_expansion(:payments, subtransaction.subtransaction_payments.ordered, {json: json, __expand: __expand, item_as: :subtransaction_payment}) do |expansion|
  expansion.handle_item_expansion
end

json.partial! subtransaction.subtransactable, as: :subtransactable, __expand: __expand
