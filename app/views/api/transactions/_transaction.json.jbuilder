# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.(transaction, :id)

json.object 'transaction'

json.created transaction.created.to_i

handle_expansion(:supporter, transaction.supporter, { json: json, __expand: __expand })

handle_expansion(:nonprofit, transaction.nonprofit, { json: json, __expand: __expand })

json.nonprofit transaction.nonprofit.id

json.amount do
	json.partial! '/api/common/amount', amount: transaction.amount_as_money
end

handle_expansion(:subtransaction, transaction.subtransaction, { json: json, __expand: __expand })

handle_array_expansion(:transaction_assignments, transaction.transaction_assignments,
																							{ json: json, __expand: __expand, item_as: :transaction_assignment }) do |tra, opts|
	handle_item_expansion(tra, opts)
end

json.payments transaction.payments do |subt_p|
	json.merge! subt_p.to_id.attributes!
end

json.url api_nonprofit_transaction_url(transaction.nonprofit, transaction)
