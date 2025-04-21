# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class RecurringDonationsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!, except: [:create]

    # get /nonprofits/:nonprofit_id/recurring_donations
    def index
      @nonprofit = current_nonprofit
      @panels_layout = true
      respond_to do |format|
        format.html
        format.json do
          # set dashboard params include externally active and failed
          # TODO move into javascript
          params[:active] = true

          render json: QueryRecurringDonations.full_list(params[:nonprofit_id], params)
        end
      end
    end

    def export
      begin
        @nonprofit = current_nonprofit
        @user = current_user_id
        # TODO: move into javascript
        if params.key?(:active_and_not_failed)
          params.delete(:active) if params.key?(:active)
          params.delete(:failed) if params.key?(:failed)
        end

        %i[active_and_not_failed active failed].each do |k|
          if params.key?(k)
            params[k] = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(params[k])
          end
        end

        params[:root_url] = root_url

        ExportRecurringDonations.initiate_export(@nonprofit.id, params, current_user.id)
      rescue => e
        e
      end
      if e.nil?
        flash[:notice] = "Your export was successfully initiated and you'll be emailed at #{current_user.email} as soon as it's available. Feel free to use the site in the meantime."
        render json: {}, status: :ok
      else
        render json: e, status: :ok
      end
    end

    def show
      @recurring_donation = current_recurring_donation
      respond_to do |format|
        format.json do
          render locals: {recurring_donation: @recurring_donation}
        end
      end
    end

    def destroy
      UpdateRecurringDonations.cancel(params[:id], current_user.email)
      json_saved current_recurring_donation
    end

    def update
      json_saved UpdateRecurringDonations
        .update(current_recurring_donation, recurring_donation_params)
    end

    # post /nonprofits/:nonprofit_id/recurring_donations
    def create
      if recurring_donation_params[:token]
        render_json { InsertRecurringDonation.with_stripe(recurring_donation_params) }
      elsif recurring_donation_params[:direct_debit_detail_id]
        render JsonResp.new(recurring_donation_params) do |_data|
          requires(:amount).as_int
          requires(:supporter_id, :nonprofit_id, :direct_debit_detail_id).as_int
          optional(:dedication, :designation).as_string
          optional(:campaign_id, :event_id).as_int
        end.when_valid do |data|
          InsertRecurringDonation.with_sepa(data)
        end
      else
        render json: {}, status: 422
      end
    end

    private

    def current_recurring_donation
      @recurring_donation ||= current_nonprofit.recurring_donations.find params[:id]
    end

    def recurring_donation_params
      params.require(:recurring_donation).permit(:amount, :active, :paydate, :interval, :time_unit, :start_date, :end_date, :n_failures, :edit_token, :cancelled_by, :cancelled_at, :donation_id, :nonprofit_id, :supporter_id)
    end
  end
end
