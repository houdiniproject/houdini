# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
class PayoutsController < ApplicationController
	include Controllers::NonprofitHelper

	before_filter :authenticate_nonprofit_admin!, only: :create
	before_filter :authenticate_nonprofit_user!, only: [:index, :show]

	def create
		payout = InsertPayout.with_stripe(current_nonprofit.id, {
      stripe_account_id: current_nonprofit.stripe_account_id,
      email: current_user.email,
      user_ip: current_user.current_sign_in_ip,
      bank_name: current_nonprofit.bank_account.name
    }, {before_date: params[:before_date]})

		if payout['failure_message'].present?
			flash[:notice] = "The payout failed: #{payout['failure_message']}"
			render json: payout, status: :unprocessable_entity
		else
			flash[:notice] = 'We successfully submitted your payout! View status and receipts below.'
			render json: payout, status: :ok
		end
	end

	def index
		@nonprofit = Nonprofit.find(params[:nonprofit_id])
		@payouts = @nonprofit.payouts.order('created_at DESC')
    balances = QueryPayments.nonprofit_balances(params[:nonprofit_id])
		@available_total = balances['available_gross']
    @pending_total = balances['pending_gross']
		@can_make_payouts = @nonprofit.can_make_payouts
	end

  # get /nonprofits/:nonprofit_id/payouts/:id
  def show
    payout = current_nonprofit.payouts.find(params[:id])
    respond_to do |format|
      format.json{render json: payout}
      format.csv do
        payments = QueryPayments.for_payout(params[:nonprofit_id], params[:id])
        filename = "payout-#{payout.created_at.strftime("%m-%d-%Y")}"
        send_data(Format::Csv.from_vectors(payments), filename: "#{filename}.csv")
      end
    end
  end

end
end
