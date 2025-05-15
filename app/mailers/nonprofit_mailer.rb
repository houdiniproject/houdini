# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class NonprofitMailer < BaseMailer
  def refund_notification(refund_id, user_id = nil)
    @refund = Refund.find(refund_id)
    @charge = @refund.charge
    @nonprofit = @refund.payment.nonprofit
    @supporter = @refund.payment.supporter
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payments")
    if user_id
      em = User.find(user_id).email
      return unless @emails.include?(em)
      @emails = [em]
    end
    mail(to: @emails, subject: "A new refund has been made for $#{Format::Currency.cents_to_dollars(@refund.amount)}")
  end

  def new_bank_account_notification(ba)
    @nonprofit = ba.nonprofit
    @bank_account = ba
    @emails = QueryUsers.all_nonprofit_user_emails(@nonprofit.id)
    mail(to: @emails, subject: "We need to confirm the new bank account")
  end

  def pending_payout_notification(payout_id, emails = nil)
    @payout = Payout.find(payout_id)
    @nonprofit = @payout.nonprofit
    @emails = emails || QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "Payout of available balance now pending")
  end

  def successful_payout_notification(payout)
    @nonprofit = payout.nonprofit
    @payout = payout
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "Payout of available balance succeeded")
  end

  def failed_payout_notification(payout)
    @nonprofit = payout.nonprofit
    @payout = payout
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "Payout could not be completed")
  end

  def failed_recurring_donation(recurring_donation)
    @recurring_donation = recurring_donation
    @nonprofit = recurring_donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_recurring_donations")
    mail(to: @emails, subject: "A recurring donation from one of your supporters had a payment failure.")
  end

  def cancelled_recurring_donation(recurring_donation)
    @recurring_donation = recurring_donation
    @nonprofit = recurring_donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_recurring_donations")
    mail(to: @emails, subject: "A recurring donation from one of your supporters was cancelled.")
  end

  def verified_notification(nonprofit)
    @nonprofit = nonprofit
    @emails = QueryUsers.all_nonprofit_user_emails(@nonprofit.id)
    mail(to: @emails, subject: "Your nonprofit has been verified!")
  end

  def button_code(nonprofit, to_email, to_name, from_email, message, code)
    @nonprofit = nonprofit
    @to_email = to_email
    @to_name = to_name
    @from = from_email
    @message = message
    @code = code
    from = Format::Name.email_from_np(@nonprofit.name)
    mail(to: to_email, from: from, reply_to: from_email, subject: "Please include this donate button code on the website")
  end

  def invoice_payment_notification(nonprofit_id, payment)
    @nonprofit = Nonprofit.find(nonprofit_id)
    @payment = payment
    @emails = QueryUsers.all_nonprofit_user_emails(@nonprofit.id, [:nonprofit_admin])
    @month_name = Date::MONTHNAMES[payment.date.month]
    mail(to: @emails, subject: "#{Settings.general.name} Subscription Receipt for #{@month_name}")
  end

  def first_charge_email(np_id)
    @nonprofit = Nonprofit.find(np_id)
    @emails = QueryUsers.all_nonprofit_user_emails(np_id, [:nonprofit_admin])
    mail(to: @emails, reply_to: "support@commitchange.com", from: "#{Settings.general.name} Support <support@commitchange.com>", subject: "Congratulations on your first charge on #{Settings.general.name}!")
  end

  def welcome(np_id)
    @nonprofit = Nonprofit.find(np_id)
    @user = @nonprofit.users.first
    @token = @user.make_confirmation_token!
    @emails = QueryUsers.all_nonprofit_user_emails(np_id, [:nonprofit_admin])
    mail(to: @emails, reply_to: "support@commitchange.com", from: "#{Settings.general.name} Support <support@commitchange.com>", subject: "A hearty welcome from the #{Settings.general.name} team")
  end
end
