# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data refunds do |refund|
  json.extract refund, :id, :amount, :created_at, :reason, :comment
end