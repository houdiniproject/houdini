# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Address < ActiveRecord::Base
  self.abstract_class = true
  attr_accessible :address, :city, :country,
                  :state_code,
                  :supporter,
                  :zip_code,
                  :fingerprint

  belongs_to :supporter

  before_save :update_fingerprint

  validates_presence_of :supporter

  def self.find_via_fingerprint(supporter, address, city, state_code, zip_code, country)
    fingerprint = AddressComparisons.calculate_hash(supporter.id, address, city, state_code, zip_code, country)
    self.find_by_fingerprint(fingerprint)
  end

  private

  def update_fingerprint
    self.fingerprint = AddressComparisons.calculate_hash(self.supporter.id, self.address, self.city, self.state_code, self.zip_code, self.country)
  end
end
