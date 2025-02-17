# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Houdini::Maintenance do
  PAGE = "https://something.c"
  TOKEN = "TOKEN"
  it "sets active to false as default" do
    m = Houdini::Maintenance.new
    expect(m.active).to be_falsy
  end

  it "accepts proper items" do
    m = Houdini::Maintenance.new(active: true, page: PAGE, token: TOKEN)
    expect(m.active).to eq true
    expect(m.page).to eq PAGE
    expect(m.token).to eq TOKEN
  end
end
