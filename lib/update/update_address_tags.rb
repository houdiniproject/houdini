# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateAddressTags
  # @param [Supporter] supporter
  # @param [Address] address
  def self.set_default_address(supporter, address)
    # let's make sure it belongs to the supporter
    supporter.addresses.find(address.id)

    result = supporter
        .address_tags
        .where(:name => 'default')

    first = result.first
    if first
      first.address = address
      first.save!
      return first
    else
     i = result.create!(address: address)
     return i
    end
  end
end