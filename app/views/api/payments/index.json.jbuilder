# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @subtransaction_payments, as: :subtransaction_payment

json.current_page @subtransaction_payments.current_page
json.first_page @subtransaction_payments.first_page?
json.last_page @subtransaction_payments.last_page?
json.requested_size @subtransaction_payments.limit_value
json.total_count @subtransaction_payments.total_count
