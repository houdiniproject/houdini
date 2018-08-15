class TransactionAddress < Address
  has_one :donation
  has_one :ticket
end
