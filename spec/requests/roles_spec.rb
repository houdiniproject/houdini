# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe RolesController, type: :request do
  let(:nonprofit) { create(:nonprofit_base) }
  let(:admin) { create(:user_as_nonprofit_admin, nonprofit: nonprofit) }

  before { sign_in admin }

  def add_role(name, email: "newperson@example.com")
    post nonprofit_roles_path(nonprofit_id: nonprofit.id), params: {role: {name: name, email: email}, format: :json}
  end

  %w[super_admin super_associate campaign_editor event_editor bogus].each do |name|
    it "refuses to grant #{name}" do
      expect { add_role(name) }.not_to change(Role, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  it "can't make the admin a super admin" do
    add_role("super_admin", email: admin.email)

    expect(QueryRoles.user_has_role?(admin.id, [:super_admin])).to be false
  end

  it "grants nonprofit_associate on the admin's nonprofit" do
    expect { add_role("nonprofit_associate") }.to change { Role.where(host: nonprofit, name: "nonprofit_associate").count }.by(1)
    expect(response).to have_http_status(:ok)
  end
end
