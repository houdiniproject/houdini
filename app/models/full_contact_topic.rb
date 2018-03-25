class FullContactTopic < ActiveRecord::Base

	attr_accessible \
    :provider,
    :value,
    :full_contact_info_id, :full_contact_info

  belongs_to :full_contact_info

end
