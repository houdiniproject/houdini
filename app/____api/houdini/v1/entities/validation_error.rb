# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::V1::Entities::ValidationError < Grape::Entity
  expose :params, documentation: { type: 'String', desc: 'Params where the following had an error.', is_array: true }
  expose :messages, documentation: { type: 'String', desc: 'The validation messages for the params', is_array: true }
end
