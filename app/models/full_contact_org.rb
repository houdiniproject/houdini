# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class FullContactOrg < ApplicationRecord
  # :name,
  # :is_primary,
  # :name,
  # :start_date,
  # :end_date,
  # :title,
  # :current,
  # :full_contact_info_id, :full_contact_info

  belongs_to :full_contact_info
end
