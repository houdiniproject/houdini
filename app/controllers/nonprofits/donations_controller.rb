# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class DonationsController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!, only: %i[index update]
    before_action :authenticate_campaign_editor!, only: [:create_offsite]

    # get /nonprofit/:nonprofit_id/donations
    def index
      redirect_to controller: :payments, action: :index
    end # def index

    # post /nonprofits/:nonprofit_id/donations
    def create
      if params[:token] 
        @result =  InsertDonation.with_stripe(donations_params.merge(token:params[:token]), current_user) 
      
      elsif params[:direct_debit_detail_id]
        render JsonResp.new(donations_params) do |_data|
          requires(:amount).as_int
          requires(:supporter_id, :nonprofit_id)
          # TODO
          # requires_either(:card_id, :direct_debit_detail_id).as_int
          optional(:dedication, :designation).as_string
          optional(:campaign_id, :event_id).as_int
        end.when_valid do |data|

          InsertDonation.with_sepa(data)
        end
        end
    end

    # post /nonprofits/:nonprofit_id/donations/create_offsite
    def create_offsite
      render JsonResp.new(donations_params) do |_data|
        requires(:amount).as_int.min(1)
        requires(:supporter_id, :nonprofit_id).as_int
        optional(:dedication, :designation).as_string
        optional(:campaign_id, :event_id).as_int
        optional(:date).as_date
        optional(:offsite_payment).nested do
          optional(:kind).one_of('cash', 'check')
          optional(:check_number)
        end
      end.when_valid { |data| InsertDonation.offsite(data) }
    end

    def update
      render_json { UpdateDonation.update_payment(params[:id], donations_params) }
    end

    # put /nonprofits/:nonprofit_id/donations/:id
    # update designation, dedication, or comment on a donation in the followup
    def followup
      nonprofit = Nonprofit.find(params[:nonprofit_id])
      donation = nonprofit.donations.find(params[:id])
      json_saved UpdateDonation.from_followup(donation, donations_params)
    end

    private

    def current_campaign
      if !@campaign && donations_params && donations_params[:campaign_id]
        @campaign = Campaign.where('id = ? ', donations_params[:campaign_id]).first
      end
      @campaign
    end

    def current_campaign_editor?
      !params[:preview] && (current_nonprofit_user? || (current_campaign && current_role?(:campaign_editor, current_campaign.id)) || current_role?(:super_admin))
    end

    def authenticate_campaign_editor!
      unless current_campaign_editor?
        block_with_sign_in 'You need to be a campaign editor to do that.'
      end
    end

    private
    def donations_params
      params.require(:donation).permit(:date, :amount, :recurring, :anonymous, :email, :designation, :dedication, :comment, :origin_url, :nonprofit_id, :card_id, :supporter_id, :profile_id, :campaign_id, :payment_id, :event_id, :direct_debit_detail_id, :token)
    end
  end
end
