# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(subtransaction.subtransactable, :id)

json.type "subtransaction"
json.supporter subtransaction.supporter.id
json.nonprofit subtransaction.nonprofit.id
json.transaction subtransaction.trx.id

json.partial! subtransaction.subtransactable, as: :subtransactable

json.payments subtransaction.payments do |py|
  json.partial! py, as: :subtransaction_payment
end

json.url api_nonprofit_transaction_subtransaction_url(subtransaction.nonprofit, subtransaction.trx)
