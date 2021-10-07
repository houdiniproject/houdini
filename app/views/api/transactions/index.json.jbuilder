# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.data @transactions, partial: '/api/transactions/transaction', as: 'transaction'

json.current_page @transactions.current_page
json.first_page @transactions.first_page?
json.last_page @transactions.last_page?
json.requested_size @transactions.limit_value
json.total_count @transactions.total_count
