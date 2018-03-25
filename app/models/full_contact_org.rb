class FullContactOrg < ActiveRecord::Base

	attr_accessible \
    :name,
    :is_primary,
    :name,
    :start_date,
    :end_date,
    :title,
    :current,
    :full_contact_info_id, :full_contact_info

  belongs_to :full_contact_info

end
