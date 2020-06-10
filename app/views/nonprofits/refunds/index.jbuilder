# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.data refunds do |refund|
  json.extract refund, :id, :amount, :created_at, :reason, :comment
end