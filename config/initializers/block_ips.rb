# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
Rack::Attack.blocklist('block charge abusers') do |req|
  ['54.159.242.229',
   '54.161.246.233',
   '54.211.94.199'].include? req.ip
end
