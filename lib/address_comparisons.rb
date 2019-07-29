# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module AddressComparisons
  def self.calculate_hash(supporter_id, address, city, state_code, zip_code, country)
    OpenSSL::Digest::SHA224.new(safely_delimited_address_string(supporter_id: supporter_id, address: (address || "").downcase, city: (city ||"").downcase, state_code: (state_code || "").downcase, zip_code: (zip_code || "").downcase, country: (country || "").downcase)).hexdigest
  end

  def self.safely_delimited_address_string(address_parts)
    JSON::generate(address_parts)
  end
end