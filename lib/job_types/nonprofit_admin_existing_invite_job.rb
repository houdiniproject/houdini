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