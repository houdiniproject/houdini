# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CardHelper
  def expiration_years
    (0..15).map { |n| (Date.today + n.years).year }
  end
end
