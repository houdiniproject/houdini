# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Paged < Grape::Entity
  expose :page_number, documentation: {type: Integer}
  expose :page_length, documentation: {type: Integer}
  expose :total, documentation: {type: Integer}
end