# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

def run_throttle?
  Rails.env != 'test' || (defined? FORCE_THROTTLE && FORCE_THROTTLE)
end


if ENV['THROTTLE_CARD_L1_LIMIT'] && ENV['THROTTLE_CARD_L1_PERIOD']
  Rack::Attack.throttle('post to add card by supporter LEVEL 1', limit:ENV['THROTTLE_CARD_L1_LIMIT'].to_i, period: ENV['THROTTLE_CARD_L1_PERIOD'].to_i) do |req|
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
end

if ENV['THROTTLE_CARD_L2_LIMIT'] && ENV['THROTTLE_CARD_L2_PERIOD']
  Rack::Attack.throttle('post to add card by supporter LEVEL 2', limit:ENV['THROTTLE_CARD_L2_LIMIT'].to_i, period: ENV['THROTTLE_CARD_L2_PERIOD'].to_i) do |req|
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
end

if ENV['THROTTLE_CARD_FINGERPRINT_L2_LIMIT'] && ENV['THROTTLE_CARD_FINGERPRINT_L2_PERIOD']
  Rack::Attack.throttle('post to add card by token LEVEL 2', limit:ENV['THROTTLE_CARD_FINGERPRINT_L2_LIMIT'].to_i, period: ENV['THROTTLE_CARD_FINGERPRINT_L2_PERIOD'].to_i) do |req|
    ret = nil
    if run_throttle? && req.path == '/cards' && req.post?
      begin
        json = JSON.parse(req.body.string)
        if json['card']['stripe_card_token']
          token = Stripe::Token.retrieve(json['card']['stripe_card_token'])
          ret = token.card.fingerprint
        end
      rescue
        req.body.rewind
      end
    end

    ret
  end
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


Rack::Attack.throttled_response = lambda do |env|
  [ 429, {'Content-Type' => 'application/json'}, [JSON.generate({'error': "I'm sorry; you're not allowed to add a card that often to a single supporter. Please contact support@commitchange.com for help."})]]
end
