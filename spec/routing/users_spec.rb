# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "Users", type: :routing do
  it "no longer routes /users/exists" do
    expect(get: "/users/exists").not_to route_to(controller: "users/confirmations", action: "exists")
  end
end
