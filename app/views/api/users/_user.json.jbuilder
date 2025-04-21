# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.extract! user, :id

json.roles user.roles do |role|
  json.partial! "api/roles/role", role: role
end

json.object "user"
