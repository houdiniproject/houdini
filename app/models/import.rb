# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Import < ApplicationRecord
  # :user_id, :user,
  # :email, # email of the user who ma
  # :nonprofit_id, :nonprofit,
  # :row_count,
  # :imported_count,
  # :date

  has_many :supporters
  belongs_to :nonprofit
  belongs_to :user

  validates :user, presence: true
end
