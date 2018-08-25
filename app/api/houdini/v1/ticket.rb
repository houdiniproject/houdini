
# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Ticket < Grape::API
  before do

    protect_against_forgery
    #make sure logged in user can handle this!
  end

  route_param :id, type:Integer do
    desc 'Return an ticket.' do
      success Houdini::V1::Entities::Ticket
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    get do
      ticket = Ticket.includes(:supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_nonprofit_user?(ticket.supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      present ticket, as: Houdini::V1::Entities::Ticket
    end


    desc 'Update an ticket.' do
      success Houdini::V1::Entities::Ticket
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

    end
  end
end