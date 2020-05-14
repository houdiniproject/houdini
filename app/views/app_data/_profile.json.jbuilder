json.extract! profile, :id, :name, :country, :picture
json.url profile_path(profile)
json.pic_tiny profile.get_profile_pic(:tiny)