# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Donation < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper, Houdini::V1::Helpers::RescueHelper, Houdini::V1::Helpers::NonprofitHelper

  before do

    protect_against_forgery
  end

  route_param :id, type:Integer do
    desc 'Return an donation' do
      success Houdini::V1::Entities::Donation
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    get do
      donation = Donation.includes(:supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(donation.supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      present donation, with: Houdini::V1::Entities::Donation
    end


    desc 'Update an donation' do
      success Houdini::V1::Entities::Donation
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    params do
      requires :donation, type: Hash, documentation: {param_type: 'body'} do
        optional :address, type: Hash, documentation: {param_type: 'body'} do
          optional :address, type:String, documentation: {param_type: 'body'}
          optional :city, type:String, documentation: {param_type: 'body'}
          optional :state_code, type:String, documentation: {param_type: 'body'}
          optional :zip_code, type:String, documentation: {param_type: 'body'}
          optional :country, type:String, documentation: {param_type: 'body'}
        end
      end
    end
    put do
      declared_params = declared(params)
      Qx.transaction do

        donation = Donation.includes(:supporter => [:nonprofit => :miscellaneous_np_info] ).find(params[:id])

        #authenticate
        unless current_nonprofit_user?(donation.supporter.nonprofit)
          error!('Unauthorized', 401)
        end
        address_key_value = declared_params[:donation][:address]

        identical_address_from_one_submitted = TransactionAddress.where(fingerprint: AddressComparisons.calculate_hash(donation.supporter.id, address_key_value[:address], address_key_value[:city], address_key_value[:state_code],
                                                                                                                       address_key_value[:zip_code], address_key_value[:country])).first
        default_address_strategy = CalculateDefaultAddressStrategy
                       .find_strategy(donation
                                          .supporter.nonprofit
                                          .miscellaneous_np_info
                                          .supporter_default_address_strategy
                                          .to_sym)


        address_prior_to_change = donation.address

        # did we find the address already in the system?
        if identical_address_from_one_submitted
          # we did, let's use that for the donation
          donation.address = identical_address_from_one_submitted
        else
          # we didn't, we'll create it
          donation.address = TransactionAddress.create!({supporter: donation.supporter}.merge(address_key_value))
        end

        # did we have an address on the donation prior to the change?
        if address_prior_to_change
          # we did, let's check if it's still used by anything else
          is_prior_address_still_used = AddressToTransactionRelation.where('address_id = ? ', address_prior_to_change.id).any?

          # is it still in use?
          unless is_prior_address_still_used
            # it's not, let's destroy it
            address_prior_to_change.destroy
            # notify the default address strategy of the change so it can do whatever is necessary
            default_address_strategy.on_remove(donation.supporter,address_prior_to_change)
          end
        end

        #  did we find the address already in the system?
        if identical_address_from_one_submitted
          # we did, let's notify the Default address strategy that we're using this address
          default_address_strategy.on_use(donation.supporter, donation.address)
        else
          # we didn't, let's notify the default address strategy that we're adding a new address
          default_address_strategy.on_add(donation.supporter, donation.address)
        end

        donation.save!
        present donation, with: Houdini::V1::Entities::Donation
      end
    end
  end
end