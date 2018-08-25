# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::NotAuthorizedError < Grape::Entity
  expose :message, documentation: {type: String}
end