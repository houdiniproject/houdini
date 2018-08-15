# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Address < ActiveRecord::Base
  attr_accessible :address, :city, :country,
                  :state_code,
                  :supporter,
                  :zip_code,
                  :calculated_hash
  belongs_to :supporter

  before_save :update_calculated_hash

  def update_calculated_hash(record)
    record.calculated_hash = OpenSSL::Digest::SHA224.digest(
        safely_delimited_address_string(address, city, state_code, zip_code, country))
  end


  def safely_delimited_address_string(*address_parts)
    address_parts.map{|i| i || ""}.join("𒀁")
  end
end
