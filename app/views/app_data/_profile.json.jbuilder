# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.extract! profile, :id, :name, :country, :picture
json.url profile_path(profile)
json.pic_tiny profile.get_profile_pic(:tiny)