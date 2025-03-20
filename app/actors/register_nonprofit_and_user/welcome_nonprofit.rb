# frozen_string_literal: true

class RegisterNonprofitAndUser::WelcomeNonprofit < Actor
  input :nonprofit

  def call
    NonprofitMailer.welcome(nonprofit.id).deliver_later
  end
end
