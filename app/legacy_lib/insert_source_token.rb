# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertSourceToken
  def self.create_record(tokenizable, params = {})
    ParamValidation.new({tokenizable: tokenizable}.merge(params),
      tokenizable: {required: true},
      event: {is_a: Event},
      expiration_time: {is_integer: true, min: 1},
      max_uses: {is_integer: true, min: 1})
    if !params[:event].nil?
      max_uses = params[:max_uses] || Houdini.source_tokens.event_donation_source.max_uses
      expiration_diff = params[:expiration_time] || Houdini.source_tokens.event_donation_source.expiration_after_event
      expiration = params[:event].end_datetime + expiration_diff.to_i
    else
      max_uses = params[:max_uses] || Houdini.source_tokens.max_uses
      expiration_diff = params[:expiration_time] || Houdini.source_tokens.expiration_time
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
