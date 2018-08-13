# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

Rack::Attack.blacklist("block all icky method requests") do |request|
  !(request.get? ||
      request.head? ||
      request.post? ||
      request.delete? ||
      request.options? ||
      request.put?)

end