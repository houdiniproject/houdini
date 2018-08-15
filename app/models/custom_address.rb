class CustomAddress < Address
  attr_accessible :deleted
  scope :not_deleted, -> {where(deleted: false)}
end
