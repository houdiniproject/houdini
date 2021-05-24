# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
Rack::Attack.blocklist('block charge abusers') do |req|
  ['54.159.242.229',
   '54.161.246.233',
   '54.211.94.199'
  ].include? req.ip
end
