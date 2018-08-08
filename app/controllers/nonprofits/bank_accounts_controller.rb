# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
class BankAccountsController < ApplicationController
	include Controllers::NonprofitHelper

	before_filter :authenticate_nonprofit_admin!

	# post /nonprofits/:nonprofit_id/bank_account
	# must pass in the user's password as params[:password]
	def create
		if password_was_confirmed(params[:pw_token])
			render_json { InsertBankAccount.with_stripe(current_nonprofit, current_user, params[:bank_account]) }
		else
			render json: ["Please confirm your password"], status: :unprocessable_entity
		end
	end

	# get /nonprofits/:nonprofit_id/bank_account/confirmation
	def confirmation
		@nonprofit = Nonprofit.find(params[:nonprofit_id])
		@bank_account = @nonprofit.bank_account
	end

	# post /nonprofits/:nonprofit_id/bank_account/confirmation
	def confirm
		npo = current_nonprofit
		ba = npo.bank_account
		if params[:token] == ba.confirmation_token
			ba.update_attribute(:pending_verification, false)
			flash[:notice] = "Your bank account is now confirmed!"
			redirect_to nonprofits_payouts_path(npo)
		else
			redirect_to(nonprofits_donations_path(npo), {:flash => {:error => "We could not confirm this bank account. Please follow the exact link provided in the confirmation email."}})
		end
	end

	# get /nonprofits/:nonprofit_id/bank_account/cancellation
	def cancellation
		@nonprofit = Nonprofit.find(params[:nonprofit_id])
		@bank_account = @nonprofit.bank_account
	end

	# post /nonprofits/:nonprofit_id/bank_account/cancel
	def cancel
		npo = current_nonprofit
		ba = npo.bank_account
		if params[:token] == ba.confirmation_token
			ba.destroy
			flash[:notice] = "Your bank account has been removed."
			redirect_to nonprofits_donations_path(npo)
		else
			redirect_to(nonprofits_donations_path(npo), {:flash => {:error => "We could not remove this bank account. Please follow the exact link provided in the email."}})
		end
	end

	def resend_confirmation
		npo = current_nonprofit
		ba = npo.bank_account
		NonprofitMailer.delay.new_bank_account_notification(ba) if ba.valid?
		respond_to{|format| format.json{render json: {}}}
	end

end
end
