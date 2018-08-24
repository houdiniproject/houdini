# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertAddress

  def self.add_transaction_address_to_supporter(transaction_entity, **params)
    #verify the transaction entity and supporter match
    address = TransactionAddress.create!(transaction_entity: transaction_entity, supporter:transaction_entity.supporter, **params)

    #let's get our strategy
  end

  def self.add_custom_address_to_supporter(supporter_id, **params)

  end
end