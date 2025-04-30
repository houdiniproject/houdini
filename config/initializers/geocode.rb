# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Geocoder.configure({
  cache: Rails.cache,
  lookup: :google,
  use_https: true,
  api_key: ENV["GOOGLE_API_KEY"],
  timeout: 10
})
