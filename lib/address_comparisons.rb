# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module AddressComparisons
  # we pick a really weird character that could never be used in an address
  # The winner is Cuneiform Sign a Times A (U+12001) - https://unicode-table.com/en/12001/
  DELIMITER = "𒀁"

  def self.calculate_hash(*address_parts)
    OpenSSL::Digest::SHA224.new(safely_delimited_address_string(*address_parts)).hexdigest
  end

  def self.safely_delimited_address_string(*address_parts)
    address_parts.map do |i|
      j = i || ""
      j.strip.upcase.gsub(/[[:punct:]]/, '').gsub(DELIMITER, '')
    end.join("𒀁")
  end
end