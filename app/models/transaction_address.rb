# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TransactionAddress < Address
  has_many :address_to_transaction_relations
end
