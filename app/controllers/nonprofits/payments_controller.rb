# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Nonprofits
  class PaymentsController < ApplicationController
    include Controllers::Nonprofit::Current
    include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!

    # get /nonprofit/:nonprofit_id/payments
    def index
      @nonprofit = current_nonprofit
      respond_to do |format|
        format.html do
          @panels_layout = true
        end

        format.json do
          @response = QueryPayments.full_search(params[:nonprofit_id], params)
          render json: @response, status: :ok
        end
      end
    end # def index

    def export
      begin
        @nonprofit = current_nonprofit
        @user = current_user_id
        ExportPayments.initiate_export(@nonprofit.id, params, @user)
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
      @nonprofit = current_nonprofit
      @payment = @nonprofit.payments.find(params[:id])
      render locals: {payment: @payment}
    end # def show

    def update
      @payment = current_nonprofit.payments.find(params[:id])
      @payment.update(payment_params)
      json_saved @payment
    end

    def destroy
      @payment = current_nonprofit.payments.find(params[:id])
      if @payment.offsite_payment.nil?
        render json: {}, status: :unprocessable_entity
        nil # You may only destroy offline payments
      else
        @payment.donation.destroy if @payment.donation.present?
        @payment.tickets.destroy_all if @payment.tickets.present?
        @payment.offsite_payment.destroy
        @payment.destroy
        Qx.delete_from(:activities).where(attachment_id: params[:id]).execute
        render json: @payment, status: :ok
      end
    end

    # post /nonprofits/:nonprofit_id/payments/:id/resend_donor_receipt
    def resend_donor_receipt
      PaymentMailer.resend_donor_receipt(params[:id])
      render json: {}
    end

    # post /nonprofits/:nonprofit_id/payments/:id/resend_admin_receipt
    # pass user_id of the admin to send to
    def resend_admin_receipt
      PaymentMailer.resend_admin_receipt(params[:id], current_user.id)
      render json: {}
    end

    private

    def payment_params
      params.require(:payment).permit(:towards, :gross_amount, :refund_total, :fee_total, :kind, :date)
    end
  end # class PaymentsController
end # module Nonprofits
