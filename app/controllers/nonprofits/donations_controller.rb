# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class DonationsController < ApplicationController
    include Controllers::NonprofitHelper

    before_action :authenticate_nonprofit_user!, only: [:index, :update]
    before_action :authenticate_campaign_editor!, only: [:create_offsite]
    before_action :reject_for_deactivated_nonprofits, only: [:create]

    # get /nonprofit/:nonprofit_id/donations
    def index
      redirect_to controller: :payments, action: :index
    end # def index

    # post /nonprofits/:nonprofit_id/donations
    def create
      if params[:token]
        params[:donation][:fee_covered] = params[:fee_covered]

        params[:donation][:token] = params[:token]
        render_json { InsertDonation.with_stripe(params[:donation], current_user) }
      elsif params[:direct_debit_detail_id]
        render JsonResp.new(params[:donation]) { |data|
          requires(:amount).as_int
          requires(:supporter_id, :nonprofit_id)
          # TODO
          # requires_either(:card_id, :direct_debit_detail_id).as_int
          optional(:dedication, :designation).as_string
          optional(:campaign_id, :event_id).as_int
        }.when_valid { |data|
          InsertDonation.with_sepa(data)
        }
      end
    end

    # post /nonprofits/:nonprofit_id/donations/create_offsite
    def create_offsite
      render JsonResp.new(params[:donation]) { |data|
        requires(:amount).as_int.min(1)
        requires(:supporter_id, :nonprofit_id).as_int
        optional(:dedication, :designation).as_string
        optional(:campaign_id, :event_id).as_int
        optional(:date).as_date
        optional(:offsite_payment).nested {
          optional(:kind).one_of("cash", "check")
          optional(:check_number)
        }
      }.when_valid { |data| InsertDonation.offsite(data) }
    end

    def update
      render_json { UpdateDonation.update_payment(params[:id], params[:donation]) }
    end

    # put /nonprofits/:nonprofit_id/donations/:id
    # update designation, dedication, or comment on a donation in the followup
    def followup
      nonprofit = Nonprofit.find(params[:nonprofit_id])
      donation = nonprofit.donations.find(params[:id])
      json_saved UpdateDonation.from_followup(donation, params[:donation])
    end

    # this is a special, weird case
    private

    def current_campaign
      if !@campaign && params[:donation] && params[:donation][:campaign_id]
        @campaign = Campaign.where("id = ? ", params[:donation][:campaign_id]).first
      end
      @campaign
    end

    def current_campaign_editor?
      !params[:preview] && (current_nonprofit_user? || (current_campaign && current_role?(:campaign_editor, current_campaign.id)) || current_role?(:super_admin))
    end

    def authenticate_campaign_editor!
      unless current_campaign_editor?
        block_with_sign_in "You need to be a campaign editor to do that."
      end
    end
  end
end
