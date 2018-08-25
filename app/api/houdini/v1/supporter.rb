# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Supporter < Grape::API
  before do

    protect_against_forgery
    #make sure logged in user can handle this!
  end

  route_param :id, type:Integer do
    desc 'Return a supporter.' do
      success Houdini::V1::Entities::Supporter
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    get do
      supporter = Supporter.includes(:nonprofit).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end
      # add the default address

      present supporter, as: Houdini::V1::Entities::Supporter
    end

    put do
      declared_params = declared(params)
      supporter = Supporter.includes(:nonprofit).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      Qx.transaction do
        # set supporter info
        # set the default address
      end

      present supporter, as: Houdini::V1::Entities::Supporter
    end


  end
end