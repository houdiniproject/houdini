# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

# Super roles are global. A super role attached to a nonprofit must never count.
describe Role do
  let(:user) { create(:user) }
  let(:nonprofit) { create(:nonprofit_base) }

  it "allows a global super admin" do
    expect(Role.new(user: user, name: :super_admin)).to be_valid
  end

  it "rejects a super admin attached to a nonprofit" do
    expect(Role.new(user: user, name: :super_admin, host: nonprofit)).not_to be_valid
    expect(Role.new(user: user, name: :super_associate, host: nonprofit)).not_to be_valid
  end

  it "won't grant anything but nonprofit roles through create_for_nonprofit" do
    expect { Role.create_for_nonprofit(:super_admin, user.email, nonprofit) }.to raise_error(ArgumentError)
  end

  describe "QueryRoles.user_has_role?" do
    it "counts a global super admin" do
      Role.create!(user: user, name: :super_admin)

      expect(QueryRoles.user_has_role?(user.id, [:super_admin])).to be true
    end

    it "ignores a super admin role attached to a nonprofit" do
      Role.new(user: user, name: :super_admin, host: nonprofit).save!(validate: false)

      expect(QueryRoles.user_has_role?(user.id, [:super_admin])).to be false
      expect(QueryUsers.super_admin_emails).not_to include(user.email)
    end

    it "still finds nonprofit roles by host" do
      Role.create!(user: user, name: :nonprofit_admin, host: nonprofit)

      expect(QueryRoles.user_has_role?(user.id, [:nonprofit_admin], nonprofit.id)).to be true
    end
  end
end
