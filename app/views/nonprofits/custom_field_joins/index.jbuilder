# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

json.data @custom_field_joins do |cfj|
    json.extract! cfj, :name, :created_at, :id, :value
end

