# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DonationMailer < BaseMailer
  # Used for both one-time and recurring donations
  # can pass in array of admin user_ids to send to only some -- if falsey/empty, will send to all
  def donor_payment_notification(donation_id, payment_id, locale = I18n.locale)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    @payment = @donation.payments.find(payment_id)

    interpolation_dict.set_supporter(@donation.supporter)
    @thank_you_note = if @donation.campaign && interpolation_dict.interpolate(@donation.campaign.receipt_message).present?
      interpolation_dict.interpolate(@donation.campaign.receipt_message)
    else
      interpolation_dict.interpolate(@nonprofit.thank_you_note)
    end
    @charge = @payment.charge
    @reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    from = Format::Name.email_from_np(@nonprofit.name)
    I18n.with_locale(locale) do
      unless @donation.supporter.email.blank?
        mail(
          to: @donation.supporter.email,
          from: from,
          reply_to: @reply_to,
          subject: I18n.t("mailer.donations.donor_direct_debit_notification.subject", nonprofit_name: @nonprofit.name)
        )
      end
    end
  end

  def donor_direct_debit_notification(donation_id, payment_id, locale = I18n.locale)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit

    interpolation_dict.set_supporter(@donation.supporter)

    @thank_you_note = if @donation.campaign && interpolation_dict.interpolate(@donation.campaign.receipt_message).present?
      interpolation_dict.interpolate(@donation.campaign.receipt_message)
    else
      interpolation_dict.interpolate(@nonprofit.thank_you_note)
    end

    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email
    from = Format::Name.email_from_np(@nonprofit.name)
    I18n.with_locale(locale) do
      mail(
        to: @donation.supporter.email,
        from: from,
        reply_to: reply_to,
        subject: I18n.t("mailer.donations.donor_direct_debit_notification.subject", nonprofit_name: @nonprofit.name)
      )
    end
  end

  # Used for both one-time and recurring donations
  def nonprofit_payment_notification(donation_id, payment_id, user_id = nil)
    @donation = Donation.find(donation_id)
    @payment = @donation.payments.find(payment_id)
    @charge = @payment.charge
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? "notify_campaigns" : "notify_payments")
    if user_id
      em = User.find(user_id).email
      # return unless @emails.include?(em)
      @emails = [em]
    end
    if @emails.any?
      mail(to: @emails, subject: "Donation receipt for #{@donation.supporter.name || @donation.supporter.email}")
    end
  end

  def nonprofit_failed_recurring_donation(donation_id)
    @donation = Donation.find(donation_id)
    @nonprofit = @donation.nonprofit
    @charge = @donation.charges.last
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? "notify_campaigns" : "notify_payments")
    if @emails.any?
      mail(to: @emails, subject: "Recurring donation payment failure for #{@donation.supporter.name || @donation.supporter.email}")
    end
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
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, @donation.campaign ? "notify_campaigns" : "notify_payments")
    if @emails.any?
      mail(to: @emails, subject: "Recurring donation cancelled for #{@donation.supporter.name || @donation.supporter.email}")
    end
  end

  def nonprofit_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_recurring_donations")
    @previous_amount = previous_amount
    if @emails.any?
      mail(to: @emails, subject: "Recurring donation amount changed for #{@donation.supporter.name || @donation.supporter.email}")
    end
  end

  def donor_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    reply_to = @nonprofit.email.blank? ? @nonprofit.users.first.email : @nonprofit.email

    interpolation_dict.set_supporter(@donation.supporter)

    @thank_you_note = if @nonprofit.miscellaneous_np_info && interpolation_dict.interpolate(@nonprofit.miscellaneous_np_info.change_amount_message).present?
      interpolation_dict.interpolate(@nonprofit.miscellaneous_np_info.change_amount_message)
    end
    from = Format::Name.email_from_np(@nonprofit.name)
    @previous_amount = previous_amount
    mail(to: @donation.supporter.email, from: from, reply_to: reply_to, subject: "Recurring donation amount changed for #{@nonprofit.name}")
  end

  def nonprofit_recurring_donation_change_amount(donation_id, previous_amount = nil)
    @donation = RecurringDonation.find(donation_id).donation
    @nonprofit = @donation.nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_recurring_donations")
    @previous_amount = previous_amount
    if @emails.any?
      mail(to: @emails, subject: "Recurring donation amount changed for #{@donation.supporter.name || @donation.supporter.email}")
    end
  end

  def interpolation_dict
    @interpolation_dict ||= SupporterInterpolationDictionary.new({"NAME" => "Supporter", "FIRSTNAME" => "Supporter"})
  end
end
