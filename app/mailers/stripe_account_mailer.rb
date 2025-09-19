# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeAccountMailer < BaseMailer
  def verified(nonprofit)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    mail(to: @emails, subject: "Verification successful on #{Settings.general.name}!",
      template_name: "verified")
  end

  def conditionally_send_verified(stripe_account)
    @nonprofit = stripe_account&.nonprofit
    if @nonprofit
      verified(@nonprofit)
    end
  end

  def more_info_needed(nonprofit, deadline = nil)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")

    @deadline = @nonprofit.stripe_account_formatted_deadline if deadline
    mail(to: @emails, subject: "Urgent: More Info Needed for Your #{Settings.general.name} Verification",
      template_name: "more_info_needed")
  end

  def conditionally_send_more_info_needed(stripe_account, email_to_send_guid, override = false)
    conditionally_send(stripe_account, email_to_send_guid, override) do |stripe_account|
      if stripe_account&.nonprofit
        more_info_needed(stripe_account.nonprofit).deliver
      end
    end
  end

  def not_completed(nonprofit, deadline = nil)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    @deadline = @nonprofit.stripe_account_formatted_deadline if deadline
    mail(to: @emails, subject: "Please Complete Your #{Settings.general.name} Account Verification",
      template_name: "not_completed")
  end

  def conditionally_send_not_completed(stripe_account, email_to_send_guid, override = false)
    conditionally_send(stripe_account, email_to_send_guid, override) do |stripe_account|
      if stripe_account&.nonprofit
        more_info_needed(stripe_account.nonprofit).deliver
      end
    end
  end

  def no_longer_verified(nonprofit, deadline = nil)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_payouts")
    @deadline = @nonprofit.stripe_account_formatted_deadline if deadline
    mail(to: @emails, subject: "Additional account verification needed for #{Settings.general.name}",
      template_name: "no_longer_verified")
  end

  def conditionally_send_no_longer_verified(stripe_account)
    if stripe_account&.nonprofit
      no_longer_verified(stripe_account.nonprofit, stripe_account.deadline).deliver
    end
  end

  private

  def conditionally_send(stripe_account, email_to_send_guid, override = false, &block)
    result = nil
    if stripe_account&.nonprofit &&
        (stripe_account
        &.nonprofit_verification_process_status || override)

      if override
        result = block.call(stripe_account)
      else
        stripe_account
          .nonprofit_verification_process_status
          .with_lock("FOR UPDATE") do
            if stripe_account.nonprofit_verification_process_status
                .email_to_send_guid == email_to_send_guid || override
              result = block.call(stripe_account)
            end
          end
      end
      result
    end
  end

  def conditionally_send_on_stripe(stripe_account, &block)
    if stripe_account&.nonprofit
      block.call(stripe_account)
    end
  end
end
