# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api_new/users/current.json.jbuilder", type: :view do
  context "for user as nonprofit_admin" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2) # Rails does weird things in view specs when you use a route namespace
      assign(:user, create(:user_base, roles: [build(:role_base, :as_nonprofit_admin)]))
      render
      rendered
    end

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: false,
        roles: [
          {
            host: Nonprofit.first.to_houid
          }
        ]
      )
    }
  end

  context "for user as nonprofit_associate" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2) # Rails does weird things in view specs when you use a route namespace
      assign(:user, create(:user_as_nonprofit_associate))
      render
      rendered
    end

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: false,
        roles: []
      )
    }
  end

  context "for user as super_admin" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2) # Rails does weird things in view specs when you use a route namespace
      assign(:user, create(:user_as_super_admin))
      render
      rendered
    end

    it {
      is_expected.to include_json(
        object: "user",
        is_super_admin: true,
        roles: []
      )
    }
  end
end
