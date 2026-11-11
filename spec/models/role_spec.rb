# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe Role do
  let(:user) { create(:user) }
  let(:nonprofit) { create(:nonprofit_base) }

  it "allows a global super admin" do
    expect(build(:role, user: user, name: :super_admin)).to be_valid
  end

  it "rejects a super role attached to a nonprofit" do
    expect(build(:role, user: user, name: :super_admin, host: nonprofit)).not_to be_valid
    expect(build(:role, user: user, name: :super_associate, host: nonprofit)).not_to be_valid
  end

  it "won't grant anything but nonprofit roles through create_for_nonprofit" do
    expect { Role.create_for_nonprofit(:super_admin, user.email, nonprofit) }.to raise_error(ArgumentError)
  end
end
