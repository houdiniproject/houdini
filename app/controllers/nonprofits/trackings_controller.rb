# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class TrackingsController < ApplicationController
    # POST /nonprofits/:nonprofit_id/tracking
    def create
      render JsonResp.new(params) do |_data|
        requires(:donation_id).as_int
        optional(:utm_campaign, :utm_content, :utm_medium, :utm_source).as_string
      end.when_valid do |_data|
        InsertTracking.create(params)
      end
    end
  end
end
