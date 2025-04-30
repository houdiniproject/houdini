# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

json.partial! "api_new/subtransaction_payments/subtransaction_payment",
  subtransaction_payment: event_entity.subtransaction_payment,
  __expand: build_json_expansion_path_tree(
    "supporter",
    "subtransaction",
    "subtransaction.transaction",
    "subtransaction.transaction.transaction_assignments"
  )
