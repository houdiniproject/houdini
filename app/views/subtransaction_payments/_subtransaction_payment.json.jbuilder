# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.type 'payment'

json.supporter subtransaction_payment.supporter.id
json.nonprofit subtransaction_payment.nonprofit.id
json.transaction subtransaction_payment.trx.id

json.subtransaction do 
	json.merge! subtransaction_payment.subtransaction&.to_id
end

json.partial! subtransaction_payment.paymentable, as: :paymentable

