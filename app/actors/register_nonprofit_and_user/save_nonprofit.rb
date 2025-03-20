# frozen_string_literal: true

class RegisterNonprofitAndUser::SaveNonprofit < Actor
  input :nonprofit
  def call
    nonprofit.save
  end
end
