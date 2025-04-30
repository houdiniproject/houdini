# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitAdminNewInviteJob < EmailJob
    attr_reader :role, :raw_token

    def initialize(role, raw_token)
      @role = role
      @raw_token = raw_token
    end

    def perform
      NonprofitAdminMailer.new_invite(@role, @raw_token).deliver
    end
  end
end
