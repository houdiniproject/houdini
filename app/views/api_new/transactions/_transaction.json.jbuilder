# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.id transaction.houid

json.object "transaction"

handle_expansion(:supporter, transaction.supporter, {json: json, __expand: __expand})

handle_expansion(:nonprofit, transaction.nonprofit, {json: json, __expand: __expand})

json.created transaction.created.to_i

json.amount do
  json.partial! "/api_new/common/amount", amount: transaction.amount_as_money
end

handle_expansion(:subtransaction, transaction.subtransaction, {json: json, __expand: __expand})

handle_array_expansion(:transaction_assignments, transaction.transaction_assignments, {json: json, __expand: __expand, item_as: :transaction_assignment}) do |expansion|
  expansion.handle_item_expansion
end

handle_array_expansion(:payments, transaction.payments.ordered, {json: json, __expand: __expand, item_as: :subtransaction_payment}) do |expansion|
  expansion.handle_item_expansion
end

# json.url api_nonprofit_transaction_url(transaction.nonprofit, transaction)
