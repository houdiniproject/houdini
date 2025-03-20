# frozen_string_literal: true

class RegisterNonprofitAndUser < Actor
  input :nonprofit
  input :user

  play  SaveNonprofit
  
  play  TryToFindASlug, if: -> actor {needs_to_build_slug(actor) }

  play  SaveUserAndRole,
        SendNonprofitUserToMailchimp,
        SetupBillingSubscription,
        SetupStripe,
        WelcomeNonprofit
       

  def self.needs_to_build_slug(actor)
    !actor.nonprofit.valid? && actor.nonprofit.errors[:slug] 
  end

end
