# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FullContactPhoto < ApplicationRecord
	#TODO
	# attr_accessible \
	# 	:full_contact_info,
	# 	:full_contact_info_id,
	# 	:type_id, # i.e. twitter, linkedin, facebook
	# 	:is_primary, #bool
	# 	:url #string

	belongs_to :full_contact_info

	validates_presence_of :full_contact_info
end