# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Addresses < Grape::Entity
  expose :addresses, using: Houdini::V1::Entities::Address,
         documentation: {is_array: true}
end