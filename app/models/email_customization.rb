# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailCustomization < ApplicationRecord
  belongs_to :nonprofit, required: true

  validates :name, :contents, presence: true
end
