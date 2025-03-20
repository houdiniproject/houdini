# frozen_string_literal: true

class RegisterNonprofitAndUser::SaveUserAndRole < Actor
  input :nonprofit
  input :user

  def call

    user.save!

    role = user.roles.build(host: nonprofit, name: 'nonprofit_admin')
    role.save!
  end
end
