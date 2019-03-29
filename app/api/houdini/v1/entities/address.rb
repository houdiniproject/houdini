# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Address < Grape::Entity
  expose :id, documentation: { type: Integer }
  expose :address, documentation: { type: String }
  expose :city, documentation: { type: String }
  expose :state_code, documentation: { type: String }
  expose :zip_code, documentation: { type: String }
  expose :country, documentation: { type: String }
  expose :fingerprint, documentation: { type: String }
  expose :supporter, using: Houdini::V1::Entities::SupporterStub,
         documentation: {type: 'Houdini::V1::Entities::SupporterStub'}

  expose :updated_at, documentation: {type: DateTime}
end

