class StripeAccountMailer < BaseMailer
  

  def verified(stripe_account)
    @nonprofit = np
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_payouts')
    mail(to: @emails, subject: "Verification successful on #{Settings.general.name}!")
  end

  def conditionally_send_successful_verification_notice(stripe_account)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      more_info_needed(stripe_account).deliver
    end
  end

  def more_info_needed(stripe_account)
    @nonprofit = np
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_payouts')
    mail(to: @emails, subject: "Verification successful on #{Settings.general.name}!")
  end

  def conditionally_send_more_info_needed(stripe_account)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      more_info_needed(stripe_account).deliver
    end
  end

  def verified
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def conditionally_send_verified(stripe_account)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      verified(stripe_account).deliver
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.stripe_account_mailer.not_completed.subject
  #
  def not_completed
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  def conditionally_send_not_completed(stripe_account, email_to_send_guid)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      more_info_needed(stripe_account).deliver
    end
  end

  private 
  def conditionally_send(stripe_account, email_to_send_guid, &block)
    if stripe_account.nonprofit && 
      stripe_account
      .nonprofit_verification_status_process

      stripe_account
        .nonprofit_verification_status_process
        .with_lock("FOR UPDATE") do
          if (stripe_account.nonprofit_verification_status_process
            .email_to_send_guid == email_to_send_guid)
            block(stripe_account)
          end
        end
    end
  end
  
end
