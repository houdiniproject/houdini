# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Address < ActiveRecord::Base
  attr_accessible :address, :city, :country,
                  :deleted, :name, :state_code,
                  :supporter,
                  :zip_code
  belongs_to :supporter

  has_many :donations
  has_many :tickets

  scope :not_deleted, -> {where(deleted: false)}
end
