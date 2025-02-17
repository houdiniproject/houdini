# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CardHelper
  def brand_file(brand)
    if brand == "Visa" || brand == "visa" || brand == "VISA"
      "visa"
    elsif brand == "American Express" || brand == "amex"
      "amex"
    elsif brand == "Discover" || brand == "Discover Card" || brand == "discover"
      "discover"
    elsif brand == "MasterCard" || brand == "Mastercard" || brand == "mastercard"
      "mastercard"
    end
  end

  def current_card
    current_user&.profile&.card
  end

  def expiration_years
    (0..15).map { |n| (Date.today + n.years).year }
  end
end
