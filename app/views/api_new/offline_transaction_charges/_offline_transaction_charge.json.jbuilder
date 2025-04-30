# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.object "offline_transaction_charge"

json.created paymentable.created.to_i

json.kind paymentable.subtransaction_payment.legacy_payment.offsite_payment&.kind
json.check_number paymentable.subtransaction_payment.legacy_payment.offsite_payment&.check_number

json.net_amount do
  json.partial! "/api_new/common/amount", amount: paymentable.net_amount_as_money
end

json.gross_amount do
  json.partial! "/api_new/common/amount", amount: paymentable.gross_amount_as_money
end

json.fee_total do
  json.partial! "/api_new/common/amount", amount: paymentable.fee_total_as_money
end
