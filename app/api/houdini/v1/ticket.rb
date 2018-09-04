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

          identical_address_from_one_submitted = TransactionAddress.where(fingerprint: AddressComparisons.calculate_hash(ticket.supporter.id, address_key_value[:address], address_key_value[:city], address_key_value[:state_code],
                                                                                                                         address_key_value[:zip_code], address_key_value[:country])).first
          default_address_strategy = CalculateDefaultAddressStrategy
                                         .find_strategy(ticket
                                                            .supporter.nonprofit
                                                            .miscellaneous_np_info
                                                            .supporter_default_address_strategy
                                                            .to_sym)


          address_prior_to_change = ticket.address

          # did we find the address already in the system?
          if identical_address_from_one_submitted
            # we did, let's use that for the donation
            ticket.address = identical_address_from_one_submitted
          else
            # we didn't, we'll create it
            ticket.address = TransactionAddress.create!({supporter: ticket.supporter}.merge(address_key_value))
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
              default_address_strategy.on_remove(ticket.supporter,address_prior_to_change)
            end
          end

          #  did we find the address already in the system?
          if identical_address_from_one_submitted
            # we did, let's notify the Default address strategy that we're using this address
            default_address_strategy.on_use(ticket.supporter, ticket.address)
          else
            # we didn't, let's notify the default address strategy that we're adding a new address
            default_address_strategy.on_add(ticket.supporter, ticket.address)
          end

          ticket.save!
          present ticket, with: Houdini::V1::Entities::Ticket
        end
    end
  end
end