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
      requires :donation, type: Hash do
        optional :address, type: Hash do
          optional :address, type:String
          optional :city, type:String
          optional :state_code, type:String
          optional :zip_code, type:String
          optional :country, type:String
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

        hash = AddressComparisons.calculate_hash(address_key_value[:address], address_key_value[:city], address_key_value[:state_code],
                                                 address_key_value[:zip_code], address_key_value[:country])

        identical_address = TransactionAddress.where(fingerprint: hash).first
        strategy = CalculateDefaultAddressStrategy
                       .find_strategy(donation
                                          .supporter.nonprofit
                                          .miscellaneous_np_info
                                          .supporter_default_address_strategy
                                          .to_sym)


        current_address = donation.address

        if identical_address
          donation.address = identical_address
        else
          donation.address = TransactionAddress.create!(declared_params)
        end

        # if the address was already used, let's make sure it is used elsewhere. if not, we delete!
        if current_address
          is_address_used = AddressToTransactionRelation.where('address_id = ? ', current_address.id).any?

          unless is_address_used
            current_address.destroy
            strategy.on_remove(current_address)
          end
        end

        if identical_address
          strategy.on_use(donation.supporter, donation.address)
        else
          strategy.on_add(donation.supporter, donation.address)
        end

        donation.save!
        present donation, with: Houdini::V1::Entities::Donation
      end
    end
  end
end