# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe User, type: :model do
  describe "super_admin?" do
    let(:super_admin) {
      sa = create(:user)

      sa.roles.create(name: "super_admin")
      sa
    }

    let(:not_super_admin) {
      sa = create(:user)
      sa.roles.create(name: "nonprofit_admin")
      sa.roles.create(name: "nonprofit_associate")
      sa
    }

    let(:no_roles) {
      sa = create(:user)
      sa
    }

    it "returns true for super admin" do
      expect(super_admin).to be_super_admin
    end

    it "returns false for not super admin" do
      expect(not_super_admin).to_not be_super_admin
    end

    it "returns false when has no roles" do
      expect(no_roles).to_not be_super_admin
    end
  end
end
