# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class BankAccountsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_admin!

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
      nonprofit = current_nonprofit
      bank_account = nonprofit.bank_account
      if params[:token] == bank_account.confirmation_token
        bank_account.update_attribute(:pending_verification, false)
        flash[:notice] = "Your bank account is now confirmed!"
        redirect_to nonprofits_payouts_path(nonprofit)
      else
        redirect_to(nonprofits_donations_path(nonprofit), flash: {error: "We could not confirm this bank account. Please follow the exact link provided in the confirmation email."})
      end
    end

    # get /nonprofits/:nonprofit_id/bank_account/cancellation
    def cancellation
      @nonprofit = Nonprofit.find(params[:nonprofit_id])
      @bank_account = @nonprofit.bank_account
    end

    # post /nonprofits/:nonprofit_id/bank_account/cancel
    def cancel
      nonprofit = current_nonprofit
      bank_account = nonprofit.bank_account
      if params[:token] == bank_account.confirmation_token
        bank_account.destroy
        flash[:notice] = "Your bank account has been removed."
        redirect_to nonprofits_donations_path(nonprofit)
      else
        redirect_to(nonprofits_donations_path(nonprofit), flash: {error: "We could not remove this bank account. Please follow the exact link provided in the email."})
      end
    end

    def resend_confirmation
      nonprofit = current_nonprofit
      bank_account = nonprofit.bank_account
      BankAccountCreateJob.perform_later(bank_account) if bank_account.valid?
      respond_to { |format| format.json { render json: {} } }
    end

    private

    def required_params
      params.permit(:name, :confirmation_token, :account_number, :bank_name, :pending_verification, :status, :email, :deleted, :stripe_bank_account_token, :stripe_bank_account_id, :nonprofit_id)
    end
  end
end
