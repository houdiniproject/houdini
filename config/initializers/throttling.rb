# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class Rack::Attack
  def self.reset_throttle(name, discriminator)
    if (throttle = (@throttles.detect { |t| t.first == name })[1])
      throttle.reset(discriminator)
    end
  end
end

class Rack::Attack::Throttle
  def reset(discriminator)
    current_period = period.respond_to?(:call) ? period.call(req) : period
    cache.reset_count "#{name}:#{discriminator}", current_period
  end
end

class Rack::Attack::Cache
  def reset_count(unprefixed_key, period)
    epoch_time = Time.now.to_i
    # Add 1 to expires_in to avoid timing error: http://git.io/i1PHXA
    expires_in = period - (epoch_time % period) + 1
    key = "#{prefix}:#{(epoch_time / period).to_i}:#{unprefixed_key}"
    store.write(key, 0, expires_in: expires_in)
  end
end

def run_throttle?
  !Rails.env.test? || (defined? FORCE_THROTTLE && FORCE_THROTTLE)
end

if ENV["THROTTLE_CARD_L1_LIMIT"] && ENV["THROTTLE_CARD_L1_PERIOD"]
  Rack::Attack.throttle("post to add card by supporter LEVEL 1", limit: ENV["THROTTLE_CARD_L1_LIMIT"].to_i, period: ENV["THROTTLE_CARD_L1_PERIOD"].to_i) do |req|
    ret = nil
    if run_throttle? && req.path == "/cards" && req.post?
      begin
        json = JSON.parse(req.body.string)
        if json["card"]["holder_type"] == "Supporter"
          ret = json["card"]["holder_id"]
        end
      rescue
        req.body.rewind
      end
    end

    ret
  end
end

if ENV["THROTTLE_CARD_L2_LIMIT"] && ENV["THROTTLE_CARD_L2_PERIOD"]
  Rack::Attack.throttle("post to add card by supporter LEVEL 2", limit: ENV["THROTTLE_CARD_L2_LIMIT"].to_i, period: ENV["THROTTLE_CARD_L2_PERIOD"].to_i) do |req|
    ret = nil
    if run_throttle? && req.path == "/cards" && req.post?
      begin
        json = JSON.parse(req.body.string)
        if json["card"]["holder_type"] == "Supporter"
          ret = json["card"]["holder_id"]
        end
      rescue
        req.body.rewind
      end
    end

    ret
  end
end
Rack::Attack.blocklist("block access to something") do |req|
  ret = nil
  # Requests are blocked if the return value is truthy
  if run_throttle? && req.path =~ /\/nonprofits\/(.*)\/supporters/ && req.post?
    begin
      json = JSON.parse(req.body.string)
      ret = json["email"] =~ /.*@itymail.com/
    rescue
      req.body.rewind
    end
  end

  ret
end

if ENV["THROTTLE_SUPPORTER_LIMIT"] && ENV["THROTTLE_SUPPORTER_PERIOD"]
  Rack::Attack.throttle("post to supporter", limit: ENV["THROTTLE_SUPPORTER_LIMIT"].to_i, period: ENV["THROTTLE_SUPPORTER_PERIOD"].to_i) do |req|
    ret = nil

    if run_throttle? && req.path =~ /\/nonprofits\/(.*)\/supporters/ && req.post?
      begin
        json = JSON.parse(req.body.string)
        ret = json["email"]
      rescue
        req.body.rewind
      end
    end

    ret
  end
end

Rack::Attack.throttled_response = lambda do |env|
  [429, {"Content-Type" => "application/json"}, [JSON.generate({error: "I'm sorry; something went wrong. Please contact support@commitchange.com for help."})]]
end
