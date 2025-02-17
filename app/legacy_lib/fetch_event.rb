# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module FetchEvent
  def self.with_params(params, nonprofit = nil)
    nonprofit ||= FetchNonprofit.with_params(params)
    if params[:event_slug]
      nonprofit.events.find_by_slug(params[:event_slug])
    elsif params[:event_id] || params[:id]
      nonprofit.events.find(params[:event_id] || params[:id])
    end
  end
end
