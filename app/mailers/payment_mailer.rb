# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PaymentMailer < BaseMailer

  # Send a donation receipt to a single admin
  # or a ticket receipt
  def resend_admin_receipt(payment_id, user_id)
    payment = Payment.find(payment_id)
    if payment.kind == 'Donation' || payment.kind == 'RecurringDonation'
      return Delayed::Job.enqueue JobTypes::NonprofitPaymentNotificationJob.new(payment.donation.id, user_id)
    elsif payment.kind == 'Ticket'
      return TicketMailer.receipt_admin(payment.donation.id, user_id).deliver
    end
  end

  # Send a donation receipt to the donor
  # or a ticket followup email to the supporter
  def resend_donor_receipt(payment_id)
    payment = Payment.find(payment_id)
    if payment.kind == 'Donation' || payment.kind == 'RecurringDonation'
      Delayed::Job.enqueue JobTypes::DonorPaymentNotificationJob.new(payment.donation.id)
    elsif payment.kind == 'Ticket'
      return TicketMailer.followup(payment.tickets.pluck(:id), payment.charge.id).deliver
    end
  end

end
