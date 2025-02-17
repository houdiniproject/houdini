# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::FullContact::Job < ApplicationRecord
  self.table_name = "full_contact_jobs"
  belongs_to :supporter, class_name: Houdini.core_classes.fetch(:supporter)
end
