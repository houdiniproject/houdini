# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
  class PaymentsController < ApplicationController
    include Controllers::NonprofitHelper

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
    end # def show

    def update
      @payment = current_nonprofit.payments.find(params[:id])
      @payment.update_attributes(params[:payment])
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
      payment = Payment.find(params[:id])
      if payment.kind == "Donation" || payment.kind == "RecurringDonation"
        JobQueue.queue(JobTypes::DonorPaymentNotificationJob, payment.donation.id, payment.id)
      elsif payment.kind == "Ticket"
        TicketMailer.followup(payment.tickets.pluck(:id), payment.charge.id).deliver
      elsif payment.kind == "Refund"
        Delayed::Job.enqueue JobTypes::DonorRefundNotificationJob.new(payment.refund.id)
      end
      render json: {}
    end

    # post /nonprofits/:nonprofit_id/payments/:id/resend_admin_receipt
    # pass user_id of the admin to send to
    def resend_admin_receipt
      payment = Payment.find(params[:id])
      if payment.kind == "Donation" || payment.kind == "RecurringDonation"
        JobQueue.queue(JobTypes::NonprofitPaymentNotificationJob, payment.donation.id, payment.id, current_user.id)
      elsif payment.kind == "Ticket"
        JobQueue.queue(JobTypes::TicketMailerReceiptAdminJob, payment.tickets.pluck(:id), current_user.id)
      elsif payment.kind == "Refund"
        Delayed::Job.enqueue JobTypes::NonprofitRefundNotificationJob.new(payment.refund.id, current_user.id)
      end
      render json: {}
    end
  end # class PaymentsController
end # module Nonprofits
