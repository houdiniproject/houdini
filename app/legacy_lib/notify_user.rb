# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module NotifyUser
  def self.send_confirmation_email(user_id)
    ParamValidation.new({user_id: user_id}, user_id: {required: true, is_integer: true})
    user = User.where("id = ?", user_id).first
    if !user
      raise ParamValidation::ValidationError.new("#{user_id} is not a valid user id", {key: :user_id, val: user_id})
    end

    user.send_confirmation_instructions
  end
end
