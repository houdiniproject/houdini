# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchEvent
  def self.with_params(params, nonprofit = nil)
    nonprofit ||= FetchNonprofit.with_params(params)
    if params[:event_slug]
      return nonprofit.events.find_by_slug(params[:event_slug])
    elsif params[:event_id] || params[:id]
      return nonprofit.events.find(params[:event_id] || params[:id])
    end
  end
end
