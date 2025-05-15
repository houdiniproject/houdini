# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.partial! "api_new/transaction_assignments/transaction_assignment",
  transaction_assignment: event_entity.transaction_assignment,
  __expand: build_json_expansion_path_tree(
    "transaction",
    "transaction.transaction_assignments",
    "transaction.subtransaction.payments"
  )
