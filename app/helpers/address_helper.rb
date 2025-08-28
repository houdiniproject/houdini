# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module AddressHelper
  def google_maps_url(event)
    "https://maps.google.com/?" + {q: Format::Address.full_address(event.address, event.city, event.state_code, event.zip_code)}.to_param
  end
end
