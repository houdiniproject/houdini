# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RegisterNonprofitForm::UserForm < ApplicationForm
  attr_accessor :email,
    :name,
    :password,
    :password_confirmation

  validates :name, :password_confirmation, presence: true

  def initialize(attributes={})
    super(attributes)
    @models = [
      user,
    ]
  end

  def user
    @user ||= User.new(
      email: email,
      name: name,
      password: password,
      password_confirmation: password_confirmation,
    )
  end
end
