# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-laterj
json.extract! user, :id, :created_at, :updated_at, :email
json.unconfirmed_email user.unconfirmed_email
json.confirmed user.confirmed?

json.partial! 'app_data/profile.json', profile: user.profile
