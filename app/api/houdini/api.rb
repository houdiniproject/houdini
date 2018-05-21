# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::API < Grape::API
  format :json
  mount Houdini::V1::API => '/v1'
end