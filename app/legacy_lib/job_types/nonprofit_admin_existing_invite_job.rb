# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitAdminExistingInviteJob < EmailJob
    attr_reader :role

    def initialize(role)
      @role = role
    end

    def perform
      NonprofitAdminMailer.existing_invite(@role).deliver
    end
  end
end
