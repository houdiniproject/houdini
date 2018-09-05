# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Donation < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper,
          Houdini::V1::Helpers::RescueHelper,
          Houdini::V1::Helpers::NonprofitHelper

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

        donation = QueryTransactionAddress::update_address(donation, address_key_value)

        donation.save!
        present donation, with: Houdini::V1::Entities::Donation
      end
    end
  end
end