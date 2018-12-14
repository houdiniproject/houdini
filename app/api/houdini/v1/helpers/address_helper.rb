# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::V1::Helpers::AddressHelper
  extend Grape::API::Helpers

  params :address do
    optional :address, type:String, desc: "Address lines", allow_blank: true, documentation: {param_type: 'body'}
    optional :city, type:String, desc: "address city", allow_blank: true, documentation: {param_type: 'body'}
    optional :state_code, type:String, desc: "State/Region code",  allow_blank: true, documentation: {param_type: 'body'}
    optional :zip_code, type:String, desc: "ZIP/Postal code", allow_blank: true, documentation: {param_type: 'body'}
    optional :country, type:String, desc: "Country", allow_blank: true, documentation: {param_type: 'body'}
  end
end