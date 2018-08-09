# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::Address < Grape::Entity
  expose :id
  expose :name
  expose :address
  expose :city
  expose :state_code
  expose :zip_code
  expose :country
  expose :supporter do
    expose :id
  end
end