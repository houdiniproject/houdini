Rack::Attack.blacklist('block charge abusers') do |req|
  ['54.159.242.229',
   '54.161.246.233',
   '54.211.94.199'
  ].include? req.ip
end
