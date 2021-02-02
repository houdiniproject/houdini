# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class TransactionAssignment < ApplicationRecord
  include Model::Houidable
  setup_houid :trxassign

  belongs_to :assignable, polymorphic: true
  belongs_to :trx, class_name: 'Transaction', foreign_key: "transaction_id"

end
