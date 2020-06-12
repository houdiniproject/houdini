# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class FullContactInfo < ApplicationRecord
  # :email,
  # :full_name,
  # :gender,
  # :city,
  # :county,
  # :state_code,
  # :country,
  # :continent,
  # :age,
  # :age_range,
  # :location_general,
  # :supporter_id, :supporter,
  # :websites

  has_many :full_contact_photos
  has_many :full_contact_social_profiles
  has_many :full_contact_orgs
  has_many :full_contact_topics
  belongs_to :supporter
end
