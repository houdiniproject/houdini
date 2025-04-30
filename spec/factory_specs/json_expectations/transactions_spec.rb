# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "trx factory" do
  it {
    expect(build(:trx, :concrete).to_h).to match(build(:trx).to_h)
  }
end
