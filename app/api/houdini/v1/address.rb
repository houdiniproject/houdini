# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Address < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper,
          Houdini::V1::Helpers::RescueHelper,
          Houdini::V1::Helpers::NonprofitHelper

  before do

    ##env['devise.mapping'] = ::Devise::Mapping.find_by_path!(request.path)

    protect_against_forgery
    #make sure logged in user can handle this!
  end

  desc 'Return an address.' do
    success Houdini::V1::Entities::Address
    failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
             {code:401, message: 'Not authorized or authenticated'}]
  end
  params do
    requires :id, type: Integer, desc: 'Address id'
  end
  route_param :id do
    get do
      address = Address.includes(:supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(address.supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      present address, as: Houdini::V1::Entities::Address
    end
  end
end