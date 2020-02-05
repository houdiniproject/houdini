class StripeAccountMailer < BaseMailer
  

  def verified(nonprofit)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_payouts')
    mail(to: @emails, subject: "Verification successful on #{Settings.general.name}!")
  end

  def conditionally_send_verified(stripe_account)
    @nonprofit = stripe_account&.nonprofit
    if @nonprofit
      verified(@nonprofit)
    end
  end

  def more_info_needed(nonprofit)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_payouts')
    mail(to: @emails, subject: "Urgent: More Info Needed for Your #{Settings.general.name} Verification")
  end

  def conditionally_send_more_info_needed(stripe_account)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      if (stripe_account&.nonprofit)
        more_info_needed(stripe_account.nonprofit).deliver
      end
    end
  end

  def not_completed(nonprofit)
    @nonprofit = nonprofit
    @emails = QueryUsers.nonprofit_user_emails(@nonprofit.id, 'notify_payouts')
    mail(to: @emails, subject: "Please Complete Your #{Settings.general.name} Account Verification")
  end

  def conditionally_send_not_completed(stripe_account, email_to_send_guid)
    conditionally_send(stripe_account, email_to_send_guid) do |stripe_account|
      if stripe_account&.nonprofit
        more_info_needed(stripe_account.nonprofit).deliver
      end
    end
  end

  private 
  def conditionally_send(stripe_account, email_to_send_guid, &block)
    if stripe_account.nonprofit && 
      stripe_account
      .nonprofit_verification_process_status

      stripe_account
        .nonprofit_verification_process_status
        .with_lock("FOR UPDATE") do
          if (stripe_account.nonprofit_verification_process_status
            .email_to_send_guid == email_to_send_guid)
            block.call(stripe_account)
          end
        end
    end
  end
  
end
