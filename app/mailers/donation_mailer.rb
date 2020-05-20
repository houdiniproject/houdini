# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DonationMailer < BaseMailer
  # Used for both one-time and recurring donations
  # can pass in array of admin user_ids to send to only some -- if falsey/empty, will send to all
  def donor_payment_notification(donation_id, locale = I18n.locale)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    if @donation.campaign && ActionView::Base.full_sanitizer.sanitize(@donation.campaign.receipt_message).present?
      @thank_you_note = @donation.campaign.receipt_message
    else
      @thank_you_note = Format::Interpolate.with_hash(@nonprofit.thank_you_note, 'NAME' => @donation.supporter.name)
    end
    @charge = @donation.charges.last
    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    from = Format::Name.email_from_np(@nonprofit.name)
    I18n.with_locale(locale) do
      mail(
        to: @donation.supporter.email,
        from: from,
        reply_to: reply_to,
        subject: I18n.t('mailer.donations.donor_direct_debit_notification.subject', nonprofit_name: @nonprofit.name)
      )
    end
  end

  def donor_direct_debit_notification(donation_id, locale = I18n.locale)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit

    if @donation.campaign && ActionView::Base.full_sanitizer.sanitize(@donation.campaign.receipt_message).present?
      @thank_you_note = @donation.campaign.receipt_message
    else
      @thank_you_note = Format::Interpolate.with_hash(@nonprofit.thank_you_note, 'NAME' => @donation.supporter.name)
    end

    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    from = Format::Name.email_from_np(@nonprofit.name)
    I18n.with_locale(locale) do
      mail(
        to: @donation.supporter.email,
        from: from,
        reply_to: reply_to,
        subject: I18n.t('mailer.donations.donor_direct_debit_notification.subject', nonprofit_name: @nonprofit.name)
      )
    end
  end

  # Used for both one-time and recurring donations
  def nonprofit_payment_notification(donation_id, user_id = nil)
    @donation = Donation.find(donation_id)
    @charge = @donation.charges.last
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? 'notify_campaigns' : 'notify_payments')
    if user_id
      em = User.find(user_id).email
      # return unless @emails.include?(em)
      @emails = [em]
    end
    mail(to: @emails, subject: "Donation receipt for #{@donation.supporter.name}")
  end

  def nonprofit_failed_recurring_donation(donation_id)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    @charge = @donation.charges.last
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? 'notify_campaigns' : 'notify_payments')
    mail(to: @emails, subject: "Recurring donation payment failure for #{@donation.supporter.name || @donation.supporter.email}")
  end

  def donor_failed_recurring_donation(donation_id)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    @charge = @donation.charges.last
    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    from = Format::Name.email_from_np(@nonprofit.name)
    mail(to: @donation.supporter.email, from: from, reply_to: reply_to, subject: "Donation payment failure for #{@nonprofit.name}")
  end

  def nonprofit_recurring_donation_cancellation(donation_id)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    @charge = @donation.charges.last
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? 'notify_campaigns' : 'notify_payments')
    mail(to: @emails, subject: "Recurring donation cancelled for #{@donation.supporter.name || @donation.supporter.email}")
   end

  def nonprofit_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_recurring_donations')
    @previous_amount = previous_amount
    mail(to: @emails, subject: "Recurring donation amount changed for #{@donation.supporter.name || @donation.supporter.email}")
  end

  def donor_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    if @nonprofit.miscellaneous_np_info && ActionView::Base.full_sanitizer.sanitize(@nonprofit.miscellaneous_np_info.change_amount_message).present?
      @thank_you_note = @nonprofit.miscellaneous_np_info.change_amount_message
    else
      @thank_you_note = nil
    end
    from = Format::Name.email_from_np(@nonprofit.name)
    @previous_amount = previous_amount
    mail(to: @donation.supporter.email, from: from, reply_to: reply_to, subject: "Recurring donation amount changed for #{@nonprofit.name}")
  end

  def nonprofit_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_recurring_donations')
    @previous_amount = previous_amount
    mail(to: @emails, subject: "Recurring donation amount changed for #{@donation.supporter.name || @donation.supporter.email}")
  end

  def donor_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    if @nonprofit.miscellaneous_np_info && ActionView::Base.full_sanitizer.sanitize(@nonprofit.miscellaneous_np_info.change_amount_message).present?
      @thank_you_note = @nonprofit.miscellaneous_np_info.change_amount_message
    else
      @thank_you_note = nil
    end
    from = Format::Name.email_from_np(@nonprofit.name)
    @previous_amount = previous_amount
    mail(to: @donation.supporter.email, from: from, reply_to: reply_to, subject: "Recurring donation amount changed for #{@nonprofit.name}")
  end
end
