# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::Api < Grape::API
  format :json
  mount Houdini::V1::Api => '/v1'
end