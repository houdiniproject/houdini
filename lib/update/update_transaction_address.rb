# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateTransactionAddress

  # @param [Hash] input
  # @param [Address|TransactionAddress] original_address
  def self.from_input(input, original_address)
    t_address = cast_to_transaction_address(original_address)

    new_hash_for_input = AddressComparisons.calculate_hash(input[:address],
                                                 input[:city],
                                                 input[:state_code],
                                                 input[:zip_code],
                                                 input[:country])

    TransactionAddress
        .where(:calculated_hash => new_hash_for_input, :supporter_id =>t_address.supporter_id)
        .first_or_create!(address:input[:address],
                          city: input[:city],
                          state_code: input[:state_code],
                          zip_code: input[:zip_code],
                          country: input[:country])


  end

  # @param [Address|TransactionAddress] address
  # @return TransactionAddress
  def self.cast_to_transaction_address(address)
    if address.is_a? TransactionAddress
      return address
    end
    if address.is_a? Address
      if address.is_a? CustomAddress
        raise ArgumentError
      end

      if address.type = 'TransactionAddress'
        return TransactionAddress.find(address.id)
      end
    end

    raise ArgumentError
  end
end