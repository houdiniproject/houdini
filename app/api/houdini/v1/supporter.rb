# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Supporter < Grape::API
  helpers Houdini::V1::Helpers::ApplicationHelper,
          Houdini::V1::Helpers::RescueHelper,
          Houdini::V1::Helpers::NonprofitHelper,
          Houdini::V1::Helpers::PagingHelper,
          Houdini::V1::Helpers::AddressHelper

  before do

    protect_against_forgery
    #make sure logged in user can handle this!
  end

  route_param :supporter_id, type:Integer do
    desc 'Return a supporter.' do
      success Houdini::V1::Entities::Supporter
      failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
               {code:404, message: 'Not found'}]
    end
    get do
      supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])

      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end
      # add the default address

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    desc 'Update a supporter.' do
      success Houdini::V1::Entities::Supporter
    end
    params do
      optional :supporter, type: Hash do
        optional :default_address, type: Hash do
          requires :id, type:Integer
        end
      end
    end
    put do
      supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
      if params[:supporter] && params[:supporter][:default_address]
        address = supporter.addresses.find(params[:supporter][:default_address][:id])
      end
      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      Qx.transaction do
        if (address)
          supporter.default_address_strategy.on_modify_default_request(address)
          supporter.reload
        end
      end

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    resource 'address' do
      desc 'Returns addresses' do
        success Houdini::V1::Entities::Addresses
      end
      params do
        optional :type, type:Symbol, values: [:CUSTOM, :ALL], default: :ALL, documentation: { param_type: 'query' }
        use :pagination
      end
      get do
        klazz = declared_params[:type] == :ALL ? Address : CustomAddress
        supporter = Supporter.includes(:nonprofit).find(declared_params[:supporter_id])

        #authenticate
        unless current_nonprofit_user?(supporter.nonprofit)
          error!('Unauthorized', 401)
        end

        addresses = klazz.includes(:supporter)
                        .where(supporter_id:supporter.id)
                        .offset(declared_params[:page_length] * declared_params[:page_number])
                        .limit(declared_params[:page_length])

        total_addresses = klazz.includes(:supporter)
                              .where(supporter_id:supporter.id).count

        present pagify({addresses: addresses}, total_addresses), with: Houdini::V1::Entities::Addresses
      end

      desc 'Create Custom Address' do
        success Houdini::V1::Entities::Addresses
      end
      params do
        requires :address, type: Hash do
          use :address
        end
      end
      post do
        Qx.transaction do
          supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
          unless current_nonprofit_user?(supporter.nonprofit) # TODO OR USING THAT CUSTOM FORM STUFF
            error!('Unauthorized', 401)
          end

          address = CustomAddress.create!({supporter:supporter}.merge(declared_params[:address]))

          supporter.default_address_strategy.on_add(supporter, address)
          present address, with: Houdini::V1::Entities::Address
        end
      end

      route_param :custom_address_id, type: Integer do
        desc 'Return a custom Address' do
          success Houdini::V1::Entities::Address
        end
        get do
          supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
          address = CustomAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:custom_address_id])

          #authenticate
          unless current_nonprofit_user?(address.supporter.nonprofit)
            error!('Unauthorized', 401)
          end

          present address, with: Houdini::V1::Entities::Address
        end

        desc 'Update a Custom Address' do
          success Houdini::V1::Entities::Address
        end
        params do
          requires :address, type: Hash do
            use :address
          end
        end
        put do
          Qx.transaction do
            supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
            address = CustomAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:custom_address_id])

            #authenticate
            unless current_nonprofit_user?(address.supporter.nonprofit)
              error!('Unauthorized', 401)
            end

            address.update_attributes!(declared_params[:address])

            supporter.default_address_strategy.on_use(address)

            present address, with: Houdini::V1::Entities::Address
          end
        end

        desc 'Delete a custom Address' do
          success Houdini::V1::Entities::Address
        end
        delete do
          Qx.transaction do
            supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
            address = CustomAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:custom_address_id])

            #authenticate
            unless current_nonprofit_user?(address.supporter.nonprofit)
              error!('Unauthorized', 401)
            end

            address.destroy

            supporter.default_address_strategy.on_remove(address)

            present address, with: Houdini::V1::Entities::Address
          end
        end
      end
    end
  end
end