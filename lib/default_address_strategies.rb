# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module DefaultAddressStrategies
  class Strategy
    # Used when an address is created for the first time
    # @param [Supporter] supporter
    # @param [Address] new_address
    # @return [AddressTag] the default address tag
    def on_add(supporter, new_address)
      Qx.transaction do
        # if first always set as default
        return first_or_create(supporter, new_address)
      end
    end

    # Used when changing the default from one address to another
    #
    # @param [Supporter] supporter
    # @param [Address] new_address
    # @return [AddressTag] the default address tag
    def on_modify_default_request(supporter, new_address)
      Qx.transaction do
        # if first always set as default
        return first_or_create(supporter, new_address)
      end
    end

    # Used when an address is removed from the database
    # @param [Supporter] supporter
    # @param [Address] removed_address
    # @return [AddressTag] the default address tag
    def on_remove(supporter, removed_address)
      Qx.transaction do
        if (!supporter.default_address)
          return nil
        end

        if (supporter.default_address_tag.address_id == removed_address.id)
          supporter.default_address.destroy
          return nil
        end
      end
    end

    # Used when an address is used. For example, when a transaction is made
    # @param [Supporter] supporter
    # @param [Address] new_address
    # @return [AddressTag] the default address tag
    def on_use(supporter, new_address)
      Qx.transaction do
        # if first always set as default
        return first_or_create(supporter, new_address)
      end
    end

    # put me in a transaction please
    def first_or_create(supporter, new_address)
      supporter.address_tags.where(name: 'default').first_or_create!(address: new_address)
    end
  end

  class ManualStrategy < Strategy


    def on_modify_default_request(supporter, new_address)
      Qx.transaction do
        ## if first, always set as default
        add = first_or_create(supporter, new_address)

        # set new_address as default
        add.address = new_address

        add.save!

        return add
      end
    end

    # Used when an address is removed from the database
    # @param [Supporter] supporter
    # @param [Address] removed_address
    # @return [AddressTag] the default address tag
    def on_remove(supporter, removed_address)
      Qx.transaction do
        super(supporter, removed_address)

        ## select next newest address
        address = supporter.addresses.not_deleted.order('updated_at DESC').first
        if (address)
          tag = first_or_create(supporter,address)
          tag.address = address
          tag.save!
          return tag
        end

        return nil
      end
    end
  end

  class AlwaysFirstStrategy < DefaultAddressStrategies::Strategy
    # Used when an address is removed from the database
    # @param [Supporter] supporter
    # @param [Address] removed_address
    # @return [AddressTag] the default address tag
    def on_remove(supporter, removed_address)
      Qx.transaction do
        unless (supporter.default_address && supporter.default_address == removed_address)
          supporter.default_address.destroy
          return nil
        else
          ## select next newest address
          address = supporter.addresses.order_by('updated_at ASC').first
          tag = first_or_create(supporter,address)
          tag.address = address
          tag.save!
          return tag
        end

      end
    end
  end

  class AlwaysLastStrategy < DefaultAddressStrategies::Strategy
    # @param [Supporter] supporter
    # @param [Address] new_address
    # @return [AddressTag] the default address tag
    def on_add(supporter, new_address)
      Qx.transaction do
        ## if first, always set as default
        add = first_or_create(supporter, new_address)

        # set new_address as default
        add.address = new_address

        add.save!

        return add
      end
    end

    alias_method :on_use, :on_add
  end


end