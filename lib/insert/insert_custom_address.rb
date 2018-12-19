# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertCustomAddress

  def create(supporter, address_data)
    address = CustomAddress.create!({supporter:supporter}.merge(address_data))
    supporter.default_address_strategy.on_add(supporter, address)
  end

  def find_or_create(supporter, address_data)
    address = CustomAddress.find_via_fingerprint(supporter, address_data[:address], address_data[:city], address_data[:state_code], address_data[:zip_code], address_data[:country])
    if (address)
      supporter.default_address_strategy.on_use(supporter, address)
    else
      address = create(supporter, address_data)
    end
    address
  end
end