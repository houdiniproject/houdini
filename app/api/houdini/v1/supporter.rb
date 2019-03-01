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
    desc 'Return a supporter.', {
      success: Houdini::V1::Entities::Supporter,
      failure: [{code:400, message:'Validation Errors',  
                model:Houdini::V1::Entities::ValidationErrors},
               {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
               {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}],
      nickname: 'getSupporter'
    }
    get do
      supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])

      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end
      # add the default address

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    desc 'Update a supporter.', {
      success: Houdini::V1::Entities::Supporter,
      failure: [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
        {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
        {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}], 
        nickname: 'updateSupporter'
      }
    params do
      optional :name, type:String, desc: "Supporter name", allow_blank: true, documentation: {param_type: 'body'}
      optional :email, type:String, desc: "Supporter email", regexp: Email::Regex, allow_blank: true, documentation: {param_type: 'body'}
      optional :phone, type:String, desc: "Supporter phone", allow_blank: 
      true, documentation: {param_type: 'body'}
      optional :organization, type:String, desc: "Supporter organization", allow_blank: true, documentation: {param_type: 'body'}
      optional :default_address, type: Hash do
        requires :id, type:Integer
      end
      
    end
    put do
      supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
      if params[:supporter] && params[:supporter][:default_address]
        address = supporter.crm_addresses.find(params[:supporter][:default_address][:id])
      end
     
      #authenticate
      unless current_nonprofit_user?(supporter.nonprofit)
        error!('Unauthorized', 401)
      end

      Qx.transaction do
        supporter.update_attributes!(declared_params[:supporter])
        if (address)
          supporter.default_address_strategy.on_set_default(address)
          supporter.reload
        end
      end

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    resource 'address' do
      desc 'Returns addresses', {
        nickname: 'getCrmAddresses',
        success: Houdini::V1::Entities::Addresses,
        failure: [{code:400, message:'Validation Errors',
          model:Houdini::V1::Entities::ValidationErrors},
          {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
          {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}]
        }
      params do
        optional :type, type:Symbol, values: [:CRM, :TRANSACTION], default: :CRM, documentation: { param_type: 'query' }
        use :pagination
      end
      get do
        klazz = declared_params[:type] == :CRM ? CrmAddress : TransactionAddress
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

      desc 'Create Custom Address', {
        success: Houdini::V1::Entities::Address,
        failure: [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
          {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
          {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}], 
          nickname: 'createCrmAddress'
        }
      params do
        use :address
      end
      post do
        Qx.transaction do
          supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
          unless current_nonprofit_user?(supporter.nonprofit) # TODO OR USING THAT CUSTOM FORM STUFF
            error!('Unauthorized', 401)
          end

          address = CrmAddress.create!(declared_params)

          supporter.default_address_strategy.on_add(address)
          present address, with: Houdini::V1::Entities::Address
        end
      end

      route_param :crm_address_id, type: Integer do
        desc 'Return a custom Address', {
          success: Houdini::V1::Entities::Address,
          failure: [{code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
            {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}],
            nickname: 'getCrmAddress'
          }
        get do
          supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
          address = CrmAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:crm_address_id])

          #authenticate
          unless current_nonprofit_user?(address.supporter.nonprofit)
            error!('Unauthorized', 401)
          end

          present address, with: Houdini::V1::Entities::Address
        end

        desc 'Update a Custom Address', {
          success: Houdini::V1::Entities::Address,
          failure: [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
            {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
            {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}],
            nickname: 'updateCrmAddress',
          }
        params do
          use :address
        end
        put do
          Qx.transaction do
            supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
            address = CrmAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:crm_address_id])

            #authenticate
            unless current_nonprofit_user?(address.supporter.nonprofit)
              error!('Unauthorized', 401)
            end

            address.update_attributes!(declared_params.except(:crm_address_id))

            present address, with: Houdini::V1::Entities::Address
          end
        end

        desc 'Delete a custom Address', {
          success: Houdini::V1::Entities::Address,
          failure: [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
            {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError},
            {code:404, message: 'Not found', model: Houdini::V1::Entities::NotFoundError}],
            nickname: 'deleteCrmAddress'
        }
        delete do
          Qx.transaction do
            supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])
            address = CrmAddress.includes(:supporter => [:nonprofit]).where(supporter_id:supporter.id).find(params[:crm_address_id])

            #authenticate
            unless current_nonprofit_user?(supporter.nonprofit)
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