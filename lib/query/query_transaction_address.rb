# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryTransactionAddress

  def self.add_or_use(supporter, address_hash=nil)
    if (address_hash.nil?)
      return nil
    end
    identical_address = TransactionAddress.where(fingerprint: AddressComparisons.calculate_hash(supporter.id, address_hash[:address], address_hash[:city], address_hash[:state_code],
                                                                                                                   address_hash[:zip_code], address_hash[:country])).first
    default_address_strategy = supporter.nonprofit.default_address_strategy

    if identical_address
      default_address_strategy.on_use(supporter, identical_address)
      return identical_address
    else
      new_address = TransactionAddress.create!({supporter: supporter}.merge(address_hash))
      default_address_strategy.on_add(supporter, new_address)
      return new_address
    end
  end

  def self.update_address(transaction, address_hash)
    remove_address_if_hanging(transaction)
    transaction.address = add_or_use(transaction.supporter, address_hash)
    return transaction
  end

  def self.remove_address_if_hanging(transaction)
    address_prior_to_change = transaction.address
    default_address_strategy = transaction.supporter.nonprofit.default_address_strategy

    # did we have an address on the donation prior to the change?
    if address_prior_to_change
      # we did, let's check if it's still used by anything else
      is_prior_address_still_used = AddressToTransactionRelation
                                        .where('address_id = ? and NOT (transactionable_id = ? AND transactionable_type = ?)',
                                               address_prior_to_change.id, transaction.id, transaction.class.name).any?

      # is it still in use?
      unless is_prior_address_still_used
        # it's not, let's destroy it
        address_prior_to_change.destroy
        # notify the default address strategy of the change so it can do whatever is necessary
        default_address_strategy.on_remove(transaction.supporter,address_prior_to_change)
      end
    end


  end
end