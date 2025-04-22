class UserInviteCreateJob < EmailJob
  def perform(role, raw_token)
    NonprofitAdminMailer.new_invite(role, raw_token).deliver_now
  end
end
