Geocoder.configure({
  cache: Rails.cache,
  lookup: :google,
  use_https: true,
  api_key: ENV['GOOGLE_API_KEY'],
  timeout: 10
})
