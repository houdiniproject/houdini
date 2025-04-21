# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NonprofitMailer < BaseMailer
  def failed_verification_notice(np)
    @nonprofit = np
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "We need some further account verification on #{Houdini.general.name}")
  end

  def successful_verification_notice(np)
    @nonprofit = np
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "Verification successful on #{Houdini.general.name}!")
  end

  def refund_notification(refund_id)
    @refund = Refund.find(refund_id)
    @charge = @refund.charge
    @nonprofit = @refund.payment.nonprofit
    @supporter = @refund.payment.supporter
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payments")
    return if @emails.blank?
    mail(to: @emails, subject: "A new refund has been made for $#{Format::Currency.cents_to_dollars(@refund.amount)}")
  end

  def new_bank_account_notification(ba)
    @nonprofit = ba.nonprofit
    @bank_account = ba
    @emails = QueryUsers.all_nonprofit_user_emails(@nonprofit.id)
    mail(to: @emails, subject: "We need to confirm the new bank account")
  end

  def pending_payout_notification(payout_id)
    @payout = Payout.find(payout_id)
    @nonprofit = @payout.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
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

  # pass in all of:
  # {is_unsubscribed_from_emails, supporter_email, message, email_unsubscribe_uuid, nonprofit_id, from_email, subject}
  def supporter_message(args)
    return if args[:is_unsubscribed_from_emails] || args[:supporter_email].blank?

    @message = args[:message]
    @uuid = args[:email_unsubscribe_uuid]
    @nonprofit = Nonprofit.find args[:nonprofit_id]
    from = Format::Name.email_from_np(@nonprofit.name)
    mail(to: args[:supporter_email], reply_to: args[:from_email], from: from, subject: args[:subject])
  end

  def setup_verification(np_id)
    @nonprofit = Nonprofit.find(np_id)
    @emails = QueryUsers.all_nonprofit_user_emails(np_id, [:nonprofit_admin])
    mail(to: @emails, reply_to: "support@commitchange.com", from: "#{Houdini.general.name} Support", subject: "Set up automatic payouts on #{Houdini.general.name}")
  end

  def welcome(np_id)
    @nonprofit = Nonprofit.find(np_id)
    @user = @nonprofit.users.first
    @token = @user.make_confirmation_token!
    @emails = QueryUsers.all_nonprofit_user_emails(np_id, [:nonprofit_admin])
    mail(to: @emails, reply_to: "support@commitchange.com", from: "#{Houdini.general.name} Support", subject: "A hearty welcome from the #{Houdini.general.name} team")
  end
end
