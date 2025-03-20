# frozen_string_literal: true

class RegisterNonprofitAndUser::SetupStripe < Actor
  input :nonprofit
  def call
    ::StripeAccountUtils.find_or_create(nonprofit.id)
  end
end
