# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
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
