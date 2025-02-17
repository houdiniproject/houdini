# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
end
