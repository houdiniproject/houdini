# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

def run_throttle?
  Rails.env != 'test' || (defined? FORCE_THROTTLE && FORCE_THROTTLE)
end

Rack::Attack.throttle('post to add card by supporter', limit:4, period: 60) do |req|
  ret = nil
  if run_throttle? && req.path == '/cards' && req.post?
    begin
      json = JSON.parse(req.body.string)
      if json['card']['holder_type'] == 'Supporter'
        ret = json['card']['holder_id']
      end
    rescue
      req.body.rewind
    end
  end

  ret
end


Rack::Attack.throttle('post to supporter', limit:10, period: 60) do |req|
  ret = nil


  if run_throttle? && req.path =~ /\/nonprofits\/(.*)\/supporters/ && req.post?
    begin
      json = JSON.parse(req.body.string)
      ret = json['email']
    rescue
      req.body.rewind
    end
  end

  ret
end
