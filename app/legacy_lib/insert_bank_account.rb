# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertBankAccount
  # @param [Nonprofit] nonprofit
  #
  # stripe_bank_account_token: data.stripe_resp.id,
  # stripe_bank_account_id: data.stripe_resp.bank_account.id,
  #   name: data.stripe_resp.bank_account.bank_name + ' *' + data.stripe_resp.bank_account.last4,
  #  email: app.user.email

  def self.with_stripe(nonprofit, user, params)
    ParamValidation.new({nonprofit: nonprofit, user: user},
      nonprofit: {
        required: true,
        is_a: Nonprofit
      },
      user: {
        required: true,
        is_a: User
      })
    ParamValidation.new(params || {},
      stripe_bank_account_token: {
        required: true,
        not_blank: true
      })

    unless nonprofit.vetted
      raise ArgumentError, "#{nonprofit.id} is not vetted."
    end

    stripe_acct = Stripe::Account.retrieve(StripeAccount.find_or_create(nonprofit.id))
    nonprofit.reload
    # this shouldn't be possible but we'll check any who
    if nonprofit.stripe_account_id.blank?
      raise ArgumentError, "#{nonprofit.id} does not have a valid stripe_account_id associated with it"
    end

    Qx.transaction do
      ba = stripe_acct.external_accounts.create(external_account: params[:stripe_bank_account_token])
      ba.default_for_currency = true
      ba.save

      BankAccount.where("nonprofit_id = ?", nonprofit.id).update_all(deleted: true)

      bank_account = BankAccount.create(
        stripe_bank_account_id: ba.id,
        stripe_bank_account_token: params[:stripe_bank_account_token],
        confirmation_token: SecureRandom.uuid,
        nonprofit: nonprofit,
        name: params[:name] || "Bank #{SecureRandom.uuid}",
        email: user.email,
        pending_verification: true
      )

      BankAccountCreateJob.perform_later(bank_account)
      bank_account
    rescue Stripe::StripeError => error
      params[:failure_message] = "Failed to connect the bank account: #{error.inspect}"
      raise ArgumentError, "Failed to connect the bank account: #{error.inspect}"
    end
  end
end
