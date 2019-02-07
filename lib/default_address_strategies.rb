# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module DefaultAddressStrategies
  class ManualStrategy
    def initialize(supporter)
      @supporter = supporter
    end

    # Used when an address is created for the first time
    # @param [Address] new_address
    # @return [AddressTag] the default address tag
    def on_add(new_address)
      Qx.transaction do
        # if first always set as default
        return first_or_create(new_address)
      end
    end

    def on_set_default(address)
      Qx.transaction do
        tag = @supporter.default_address_tag
        if address.supporter == @supporter
          tag.crm_address = address
          tag.save!
        end
        return tag
      end
    end

    # Used when an address is removed from the database
    # @param [Address] removed_address
    # @return [AddressTag] the default address tag
    def on_remove(removed_address)
      Qx.transaction do
        if (!@supporter.default_address_tag)
          return nil
        end

        ## select next newest address
        address = @supporter.crm_addresses.not_deleted.order('updated_at DESC').first
        if (address)
          tag = first_or_create(address)
          tag.crm_address = address
          tag.save!
          return tag
        end

        return nil
      end
    end
    
    # put me in a transaction please
    def first_or_create(new_address)
      @supporter.address_tags.where(name: 'default').first_or_create!(crm_address: new_address)
    end
  end
end