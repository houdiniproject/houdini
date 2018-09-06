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

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    desc 'Return a supporter.' do
      success Houdini::V1::Entities::Supporter
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

      present supporter, with: Houdini::V1::Entities::Supporter
    end

    resource 'address' do
      desc 'Returns addresses' do
        success Houdini::V1::Entities::Addresses
        failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
                 {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
      end
      params do
        optional :type, type:Symbol,  values: [:CUSTOM, :ALL], default: :ALL, documentation: { param_type: 'query' }
        optional :page_length, type:Integer, default:20, greater_than: 1, less_than_or_equal:100, documentation: { param_type: 'query' }
        optional :page_number, type:Integer, default:0, greater_than_or_equal:0, documentation: { param_type: 'query' }
      end
      get do

        klazz = declared_params[:type] == :ALL ? Address : CustomAddress
        supporter = Supporter.includes(:nonprofit).find(params[:supporter_id])

        #authenticate
        unless current_nonprofit_user?(supporter.nonprofit)
          error!('Unauthorized', 401)
        end

        addresses = klazz.includes(:supporter => [:nonprofit])
                        .where(supporter:supporter)
                        .skip(params[:page_length] * params[:page_number])
                        .limit(params[:page_length])

        present addresses, with: Houdini::V1::Addresses
      end

      desc 'Create Custom Address' do
        success Houdini::V1::Entities::Addresses
        failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
                 {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
      end
      params do
        requires :address, type: Hash do
          optional :address, type:String, desc: "Address lines", allow_blank: true, documentation: {param_type: 'body'}
          optional :city, type:String, desc: "address city", allow_blank: true, documentation: {param_type: 'body'}
          optional :state_code, type:String, desc: "State/Region code",  allow_blank: true, documentation: {param_type: 'body'}
          optional :zip_code, type:String, desc: "ZIP/Postal code", allow_blank: true, documentation: {param_type: 'body'}
          optional :country, type:String, desc: "Country", allow_blank: true, documentation: {param_type: 'body'}
        end
      end
      post do
        declared_params = declared(params)
        Qx.transaction do
          supporter = Supporter.includes(:nonprofit).find(params[:id])
          unless current_nonprofit_user?(supporter.nonprofit) # TODO OR USING THAT CUSTOM FORM STUFF
            error!('Unauthorized', 401)
          end

          address = CustomAddress.create!({supporter:supporter}.merge(declared_params[:address]))

          supporter.nonprofit.default_address_strategy.on_add(supporter, address)
          return address
        end
      end

      route_param :custom_address_id, type: Integer do
        desc 'Return a custom Address' do
          success Houdini::V1::Entities::Address
          failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
                   {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
        end
        get do
          supporter = Supporter.includes(:nonprofit).find(params[:id])
          address = CustomAddress.includes(:supporter => [:nonprofit]).where(supporter:supporter).find(params[:custom_address_id])

          #authenticate
          unless current_nonprofit_user?(address.supporter.nonprofit)
            error!('Unauthorized', 401)
          end

          present address, with: Houdini::V1::Entities::Address
        end

        desc 'Update a Custom Address' do
          success Houdini::V1::Entities::Address
          failure [{code:400, message:'Validation Errors',  model: Houdini::V1::Entities::ValidationErrors},
                   {code:401, message: 'Not authorized or authenticated', model: Houdini::V1::Entities::NotAuthorizedError}]
        end
        params do
          requires :address, type: Hash do
            optional :address, type:String, desc: "Address lines", allow_blank: true, documentation: {param_type: 'body'}
            optional :city, type:String, desc: "address city", allow_blank: true, documentation: {param_type: 'body'}
            optional :state_code, type:String, desc: "State/Region code",  allow_blank: true, documentation: {param_type: 'body'}
            optional :zip_code, type:String, desc: "ZIP/Postal code", allow_blank: true, documentation: {param_type: 'body'}
            optional :country, type:String, desc: "Country", allow_blank: true, documentation: {param_type: 'body'}
          end
        end
        put do
          declared_params = declared(params)
          Qx.transaction do
            supporter = Supporter.includes(:nonprofit).find(params[:id])
            address = CustomAddress.includes(:supporter => [:nonprofit]).where(supporter:supporter).find(params[:custom_address_id])

            #authenticate
            unless current_nonprofit_user?(address.supporter.nonprofit)
              error!('Unauthorized', 401)
            end


            address.update!(declared_params[:address])

            supporter.nonprofit.default_address_strategy.on_use(supporter, address)
            return address
          end
        end
      end
    end


  end
end