# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertCrmAddress
  mattr_accessor :address_strategy
  self.address_strategy = DefaultAddressStrategies::ManualStrategy.new
  def self.create(supporter, address_data)
    address = CrmAddress.create!({supporter:supporter}.merge(address_data))
    self.address_strategy.on_add(supporter, address)
    address
  end

  def self.find_or_create(supporter, address_data)
    address = CrmAddress.find_via_fingerprint(supporter, address_data[:address], address_data[:city], address_data[:state_code], address_data[:zip_code], address_data[:country])
    unless address
      address = create(supporter, address_data)
    end
    address
  end
end