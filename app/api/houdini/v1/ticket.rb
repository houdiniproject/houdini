# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Ticket < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper,
          Houdini::V1::Helpers::RescueHelper,
          Houdini::V1::Helpers::NonprofitHelper,
          Houdini::V1::Helpers::EventHelper
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
      ticket = Ticket.includes(:event, :supporter => [:nonprofit]).find(params[:id])

      #authenticate
      unless current_event_editor?(ticket.event)
        error!('Unauthorized', 401)
      end

      present ticket, with: Houdini::V1::Entities::Ticket
    end


    desc 'Update an ticket.' do
      success Houdini::V1::Entities::Ticket
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
    end
    params do
      requires :ticket, type: Hash, documentation: {param_type: 'body'} do
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

          ticket = Ticket.includes(:event, :supporter => [:nonprofit => :miscellaneous_np_info]).find(params[:id])

          #authenticate
          unless current_event_editor?(ticket.event)
            error!('Unauthorized', 401)
          end
          address_key_value = declared_params[:ticket][:address]

          ticket = QueryTransactionAddress::update_address(ticket, address_key_value)

          ticket.save!
          present ticket, with: Houdini::V1::Entities::Ticket
        end
    end
  end
end