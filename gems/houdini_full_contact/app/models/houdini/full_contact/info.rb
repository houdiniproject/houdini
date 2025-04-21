# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::FullContact::Info < ApplicationRecord
  self.table_name = "full_contact_infos"

  has_many :photos, foreign_key: "full_contact_info_id"
  has_many :social_profiles, foreign_key: "full_contact_info_id"
  has_many :orgs, foreign_key: "full_contact_info_id"
  has_many :topics, foreign_key: "full_contact_info_id"

  belongs_to :supporter, class_name: Houdini.core_classes.fetch(:supporter).to_s
end
