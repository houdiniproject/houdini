class Address < ActiveRecord::Base
  attr_accessible :address, :city, :country,
                  :deleted, :name, :state_code,
                  :supporter,
                  :zip_code
  belongs_to :supporter

  has_many :donations, :tickets

  scope :not_deleted, -> {where(deleted: false)}
end
