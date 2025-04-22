# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.type "trx_assignment"

json.id transaction_assignment.to_houid
# json.created transaction_assignment.acreated.to_i

handle_expansion(:supporter, transaction_assignment.supporter, {json: json, __expand: __expand})
handle_expansion(:nonprofit, transaction_assignment.nonprofit, {json: json, __expand: __expand})
handle_expansion(:transaction, transaction_assignment.trx, {json: json, __expand: __expand})

json.partial! transaction_assignment.assignable, as: :assignable, __expand: __expand
