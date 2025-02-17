# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @payments, partial: "/api/subtransaction_payments/subtransaction_payment", as: :subtransaction_payment

json.current_page @payments.current_page
json.first_page @payments.first_page?
json.last_page @payments.last_page?
json.requested_size @payments.limit_value
json.total_count @payments.total_count
