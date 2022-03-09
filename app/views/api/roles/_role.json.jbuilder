# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.(role, :id, :name)

json.user_id role.user.id
json.host role.host_type

json.object 'role'
