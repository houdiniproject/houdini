# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertSourceToken
  def self.create_record(tokenizable, params = {})
    ParamValidation.new({tokenizable: tokenizable}.merge(params), {
      tokenizable: {required: true},
      event: {is_a: Event},
      expiration_time: {is_integer: true, min: 1},
      max_uses: {is_integer: true, min: 1}
    })
    if !params[:event].nil?
      max_uses = params[:max_uses] || Settings.source_tokens.event_donation_source.max_uses
      expiration_diff = params[:expiration_time] || Settings.source_tokens.event_donation_source.time_after_event
      expiration = params[:event].end_datetime + expiration_diff.to_i
    else
      max_uses = params[:max_uses] || Settings.source_tokens.max_uses
      expiration_diff = params[:expiration_time] || Settings.source_tokens.expiration_time
      expiration = Time.now + expiration_diff.to_i
    end
    c = SourceToken.new
    c.tokenizable = tokenizable
    c.expiration = expiration
    c.token = SecureRandom.uuid
    c.max_uses = max_uses
    c.event = params[:event]
    c.save!
    c
  end
end
