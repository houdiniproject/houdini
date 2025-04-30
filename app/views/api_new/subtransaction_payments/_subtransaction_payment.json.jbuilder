# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.type "payment"

json.id subtransaction_payment.paymentable.houid
json.created subtransaction_payment.created.to_i

json.legacy_id subtransaction_payment.legacy_payment_id

json.legacy_nonprofit subtransaction_payment.nonprofit.id

handle_expansion(:supporter, subtransaction_payment.supporter, {json: json, __expand: __expand})
handle_expansion(:nonprofit, subtransaction_payment.nonprofit, {json: json, __expand: __expand})
handle_expansion(:transaction, subtransaction_payment.trx, {json: json, __expand: __expand})
handle_expansion(:subtransaction, subtransaction_payment.subtransaction, {json: json, __expand: __expand})

json.partial! subtransaction_payment.paymentable, as: :paymentable, __expand: __expand
