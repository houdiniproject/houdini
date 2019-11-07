class RoleAddedJob < ApplicationJob
  queue_as :default

  def perform(role)
    NonprofitAdminMailer.existing_invite(role).deliver_now
  end
end
