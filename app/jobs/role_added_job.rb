class RoleAddedJob < EmailJob
  def perform(role)
    NonprofitAdminMailer.existing_invite(role).deliver_now
  end
end
