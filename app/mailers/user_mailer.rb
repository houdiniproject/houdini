# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class UserMailer < BaseMailer
  def refund_receipt(refund_id)
    @refund = Refund.find(refund_id)
    @nonprofit = @refund.payment.nonprofit
    @charge = @refund.charge
    @supporter = @refund.payment.supporter
    reply_to = @nonprofit.email.presence || @nonprofit.users.first.email
    from = Format::Name.email_from_np(@nonprofit.name)
    mail(to: @supporter.email, from: from, reply_to: reply_to, subject: "Your refund receipt for #{@nonprofit.name}")
  end

  def recurring_donation_failure(recurring_donation)
    @recurring_donation = recurring_donation
    mail(to: @recurring_donation.email,
      subject: "We couldn't process your recurring donation towards #{@recurring_donation.nonprofit.name}.")
  end

  def recurring_donation_cancelled(recurring_donation)
    @recurring_donation = recurring_donation
    mail(to: @recurring_donation.email,
      subject: "Your recurring donation towards #{@recurring_donation.nonprofit.name} was successfully cancelled.")
  end
end
