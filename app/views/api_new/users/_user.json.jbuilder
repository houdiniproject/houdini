# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.object "user"

json.roles user.nonprofit_admin_roles do |role|
  json.host role.host.to_houid
end

json.is_super_admin user.roles.super_admins.any?
