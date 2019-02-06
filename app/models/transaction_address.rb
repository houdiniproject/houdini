# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TransactionAddress < Address
  belongs_to :transactionable, polymorphic: true
  validates :transactionable_id, :transactionable_type, presence: true
end
