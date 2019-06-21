# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FullContactInfo < ApplicationRecord
	#TODO
	# attr_accessible \
	# 	:email,
	# 	:full_name,
	# 	:gender,
	# 	:city,
	# 	:county,
	# 	:state_code,
	# 	:country,
	# 	:continent,
	# 	:age,
	# 	:age_range,
    # :location_general,
    # :supporter_id, :supporter,
    # :websites

	has_many :full_contact_photos
	has_many :full_contact_social_profiles
	has_many :full_contact_orgs
	has_many :full_contact_topics
  belongs_to :supporter
end
