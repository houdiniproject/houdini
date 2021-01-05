# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.extract! profile, :id, :name, :country, :picture
json.url profile_path(profile)
json.pic_tiny rails_storage_proxy_url(profile.picture_by_size(:tiny)) if profile.picture.attached?
