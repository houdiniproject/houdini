# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PaymentMailer < BaseMailer
  # Send a donation receipt to a single admin
  # or a ticket receipt
  def resend_admin_receipt(payment_id, user_id)
    payment = Payment.find(payment_id)
    if payment.kind == "Donation" || payment.kind == "RecurringDonation"
      JobQueue.queue(JobTypes::NonprofitPaymentNotificationJob, payment.donation.id, payment_id, user_id)
    elsif payment.kind == "Ticket"
      JobQueue.queue(JobTypes::TicketMailerReceiptAdminJob, payment.tickets.pluck(:id), user_id)
    elsif payment.kind == "Refund"
      Delayed::Job.enqueue JobTypes::NonprofitRefundNotificationJob.new(payment.refund.id, user_id)
    end
  end

  # Send a donation receipt to the donor
  # or a ticket followup email to the supporter
  def resend_donor_receipt(payment_id)
    payment = Payment.find(payment_id)
    if payment.kind == "Donation" || payment.kind == "RecurringDonation"
      JobQueue.queue(JobTypes::DonorPaymentNotificationJob, payment.donation.id, payment.id)
    elsif payment.kind == "Ticket"
      TicketMailer.followup(payment.tickets.pluck(:id), payment.charge.id).deliver
    elsif payment.kind == "Refund"
      Delayed::Job.enqueue JobTypes::DonorRefundNotificationJob.new(payment.refund.id)
    end
  end
end
