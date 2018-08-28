# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Address < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper,
          Houdini::V1::Helpers::RescueHelper,
          Houdini::V1::Helpers::NonprofitHelper

  before do

    protect_against_forgery
    #make sure logged in user can handle this!
  end


  route_param :id, type:Integer do
    desc 'Return an address' do
      success Houdini::V1::Entities::Address
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    get do
      address = Address.includes(:supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(address.supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      present address, with: Houdini::V1::Entities::Address
    end

    # desc 'Update a Custom Address' do
    #   success Houdini::V1::Entities::Address
    #   failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
    #            {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    # end
    # params do
    #   optional :address, type:String, desc: "Address lines", allow_blank: true, documentation: {param_type: 'body'}
    #   optional :city, type:String, desc: "address city", allow_blank: true, documentation: {param_type: 'body'}
    #   optional :state_code, type:String, desc: "State/Region code",  allow_blank: true, documentation: {param_type: 'body'}
    #   optional :zip_code, type:String, desc: "ZIP/Postal code", allow_blank: true, documentation: {param_type: 'body'}
    #   optional :country, type:String, desc: "Country", allow_blank: true, documentation: {param_type: 'body'}
    #   optional :for_transaction, type: Hash do
    #     optional :id
    #     optional :key
    #   end
    # end
    # put do
    #   declared_params = declared(params)
    #   address = Address.includes(:supporter => [:nonprofit]).find(params[:id])
    #
    #   #authenticate
    #   unless current_nonprofit_user?(address.supporter.nonprofit)
    #     error!('Unauthorized', 401)
    #   end
    #
    #   declared_params = declared_params.except(:for_transaction)
    #   case address.type
    #   when 'TransactionAddress'
    #     address = TransactionAddress.includes(:supporter => [:nonprofit]).find(address.id)
    #   when 'CustomAddress'
    #     address = CustomAddress.includes(:supporter => [:nonprofit]).find(address.id)
    #   end
    #
    #   if address is_a? TransactionAddress
    #
    #     duplicated = address.dup
    #     duplicated.update(declared_params)
    #     duplicated.save!
    #   elsif address.is? CustomAddress
    #     return address.update(declared_params)
    #   end
    #
    # end
  end
end