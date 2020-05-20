# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
json.extract! profile, :id, :name, :country, :picture
json.url profile_path(profile)
json.pic_tiny url_for(profile.picture_by_size(:tiny)) if profile.picture.attached?
