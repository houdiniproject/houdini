# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FullContactOrg < ApplicationRecord

  #TODO
	# attr_accessible \
  #   :name,
  #   :is_primary,
  #   :name,
  #   :start_date,
  #   :end_date,
  #   :title,
  #   :current,
  #   :full_contact_info_id, :full_contact_info

  belongs_to :full_contact_info

end
