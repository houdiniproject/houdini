# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Campaigns
  class DonationsController < ApplicationController
    include Controllers::Campaign::Current
    include Controllers::Campaign::Authorization

    before_action :authenticate_campaign_editor!, only: [:index]

    def index
      respond_to do |format|
        format.csv do
          file_date = Date.today.strftime("%m-%d-%Y")
          donations = QueryDonations.campaign_export(current_campaign.id)
          send_data(Format::Csv.from_vectors(donations), filename: "campaign-donations-#{file_date}.csv")
        end
      end
    end
  end
end
