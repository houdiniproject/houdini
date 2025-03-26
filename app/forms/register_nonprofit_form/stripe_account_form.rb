# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RegisterNonprofitForm::StripeAccountForm < ApplicationForm

  attr_accessor :nonprofit

  validate :nonprofit_is_a_nonprofit

  def initialize(attributes={})
    super(attributes)
    @models = []
  end

  # basically a reuse from yaaf itself
  def save(options = {})
    save!(options)
    true
  rescue ActiveRecord::RecordInvalid,
        ActiveRecord::RecordNotSaved,
        ActiveModel::ValidationError

    false
  end

  def save!(options = {})
    super(options)

    if nonprofit.persisted? &&  nonprofit.stripe_account_id.blank?
      stripe_account_id = StripeAccountUtils.create(nonprofit)
      unless stripe_account_id.present?
        add_couldnt_create_stripe_error
        raise ActiveModel::ValidationError, self
      end
      nonprofit.reload # StripeAccountUtils.create is weird and we need to reload after
    else
      add_couldnt_create_stripe_error
      raise ActiveModel::ValidationError, self
    end
  end


  private

  def nonprofit_is_a_nonprofit
    add_couldnt_create_stripe_error unless nonprofit&.is_a? Nonprofit
  end

  def add_couldnt_create_stripe_error
    errors.add(:base, "Couldn't create Stripe account. Please contact #{Settings.mailer.email} for more assistance.")
  end
end
