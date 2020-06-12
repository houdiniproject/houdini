# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class FullContactPhoto < ApplicationRecord
  # :full_contact_info,
  # :full_contact_info_id,
  # :type_id, # i.e. twitter, linkedin, facebook
  # :is_primary, #bool
  # :url #string

  belongs_to :full_contact_info

  validates_presence_of :full_contact_info
end
