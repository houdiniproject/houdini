# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CustomAddress < Address
  attr_accessible :deleted, :name
  scope :not_deleted, -> {where(deleted: false)}
end
