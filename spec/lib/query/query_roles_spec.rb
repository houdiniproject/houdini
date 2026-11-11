# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe QueryRoles do
  include_context :shared_donation_charge_context
  let(:nonprofit_admin_role) { force_create(:role, user: user, host: nonprofit, name: :nonprofit_admin) }
  let(:other_nonprofit_admin_role) { force_create(:role, user: user, host: other_nonprofit, name: :nonprofit_admin) }
  let(:nonprofit_associate_role) { force_create(:role, user: user, host: nonprofit, name: :nonprofit_associate) }
  let(:other_nonprofit_associate_role) { force_create(:role, user: user, host: other_nonprofit, name: :nonprofit_associate) }

  describe "is_nonprofit_user?" do
    it "false for no role" do
      expect(QueryRoles.is_nonprofit_user?(user.id, nonprofit.id)).to be_falsey
    end

    it "false for other nonprofit admin" do
      other_nonprofit_admin_role
      expect(QueryRoles.is_nonprofit_user?(user.id, nonprofit.id)).to be_falsey
    end

    it "false for other nonprofit associate" do
      other_nonprofit_associate_role
      expect(QueryRoles.is_nonprofit_user?(user.id, nonprofit.id)).to be_falsey
    end

    it "true for nonprofit admin" do
      nonprofit_admin_role
      expect(QueryRoles.is_nonprofit_user?(user.id, nonprofit.id)).to be_truthy
    end

    it "true for nonprofit admin" do
      nonprofit_associate_role
      expect(QueryRoles.is_nonprofit_user?(user.id, nonprofit.id)).to be_truthy
    end
  end

  describe "user_has_role?" do
    it "counts a global super admin" do
      create(:role, user: user, name: :super_admin)

      expect(QueryRoles.user_has_role?(user.id, [:super_admin])).to be true
    end

    it "ignores a super admin role attached to a nonprofit" do
      build(:role, user: user, name: :super_admin, host: nonprofit).save!(validate: false)

      expect(QueryRoles.user_has_role?(user.id, [:super_admin])).to be false
    end

    it "finds nonprofit roles by host" do
      nonprofit_admin_role

      expect(QueryRoles.user_has_role?(user.id, [:nonprofit_admin], nonprofit.id)).to be true
    end
  end
end
