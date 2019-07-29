# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateAddressTags
  # @param [Supporter] supporter
  # @param [Address] address
  def self.set_default_address(supporter, address)
    # let's make sure it belongs to the supporter
    address = supporter.crm_addresses.find(address.id)
    supporter.default_address_strategy.on_set_default(address)
  end
end