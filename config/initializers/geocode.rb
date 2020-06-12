# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
Geocoder.configure(
  cache: Rails.cache,
  lookup: Rails.env == 'test' ? :test : :google,
  use_https: true,
  api_key: ENV['GOOGLE_API_KEY'],
  timeout: 10
)