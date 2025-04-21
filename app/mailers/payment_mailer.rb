# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class PaymentMailer < BaseMailer
  # Send a donation receipt to a single admin
  # or a ticket receipt
  def resend_admin_receipt(payment_id, user_id)
    payment = Payment.find(payment_id)
    if payment.kind == "Donation" || payment.kind == "RecurringDonation"
      PaymentNotificationEmailNonprofitJob.perform_later(payment.donation, User.find(user_id))
    elsif payment.kind == "Ticket"
      TicketMailer.receipt_admin(payment.donation.id, user_id).deliver_later
    end
  end

  # Send a donation receipt to the donor
  # or a ticket followup email to the supporter
  def resend_donor_receipt(payment_id)
    payment = Payment.find(payment_id)
    if payment.kind == "Donation" || payment.kind == "RecurringDonation"
      PaymentNotificationEmailDonorJob.perform_later payment.donation, (payment&.supporter&.locale || "en")
    elsif payment.kind == "Ticket"
      TicketMailer.followup(payment.tickets.pluck(:id), payment.charge).deliver_later
    end
  end
end
