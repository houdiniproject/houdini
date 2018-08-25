# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Donation < Grape::API
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

      present donation, as: Houdini::V1::Entities::Donation
    end


    desc 'Update an donation' do
      success Houdini::V1::Entities::Donation
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    params do
      requires :ticket, type: Hash do

        optional :address, type: Hash do
          optional :address
          optional :city
          optional :state_code
          optional :zip_code
          optional :country
        end
      end
    end
    put do
      declared_params = declared(params)
      donation = Donation.includes(:supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(donation.supporter.nonprofit)
        error!('Unauthorized', 401)
      end
    end
  end
end