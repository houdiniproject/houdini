# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class NonprofitSettingsForm
  include ActiveModel::Model

  attr_accessor :nonprofit, :attributes

  def save
    return false unless valid?

    nonprofit.transaction do
      nonprofit.update!(attributes)

      if nonprofit.previous_changes["require_two_factor"] == [false, true]
        enforce_two_factor_for_all_users
      end
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def enforce_two_factor_for_all_users
    nonprofit.users.where(otp_required_for_login: false).find_each do |user|
      user.otp_required_for_login = true
      user.otp_secret = User.generate_otp_secret
      user.save(validate: false)
    end
  end
end
