# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::FullContact::Photo < ApplicationRecord
  self.table_name = "full_contact_photos"

  belongs_to :info, foreign_key: "full_contact_info_id"

  validates_presence_of :info
end
