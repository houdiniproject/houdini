# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Donation < Grape::Entity
  expose :id, documentation: { type: Integer }
  expose :address, using: Houdini::V1::Entities::Address, documentation: {type: 'Houdini::V1::Entities::Address'}
end