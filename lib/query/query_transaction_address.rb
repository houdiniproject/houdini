# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryTransactionAddress

  # UPSERT for TransactionAddress
  def self.add(supporter, address_hash=nil)
    if (address_hash.nil?)
      return nil
    end
  
    new_address = TransactionAddress.create!({supporter: supporter}.merge(address_hash))
    InsertCrmAddress.find_or_create(supporter, address_hash)
    return new_address
  end

  def self.update_address(transaction, address_hash)
    if (transaction.address)
      transaction.address.update_attributes(address_hash)
    else
      transaction.create_address!(address_hash.merge({supporter: transaction.supporter}))
    end
    return transaction
  end
end