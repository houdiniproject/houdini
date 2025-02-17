# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.extract! user, :id, :created_at, :updated_at, :email
json.unconfirmed_email user.unconfirmed_email
json.confirmed user.confirmed?

json.partial! "app_data/profile", profile: user.profile
