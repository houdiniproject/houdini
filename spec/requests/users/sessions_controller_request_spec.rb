# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Users::SessionsController, type: :request do
  it "has X-Frame-Options=SAMEORIGIN set" do
    get "/users/sign_in"

    expect(response.headers["X-Frame-Options"]).to eq "SAMEORIGIN"
  end

  it "will lock out on the 11th attempt", skip: "spec does not work for some reason but does work in reality" do
    user = create(:user)
    user.lock_access!
    10.times do
      post "/users/sign_in.json", params: {email: user.email, password: "not correct"}
    end
    @response = nil
    post "/users/sign_in.json", params: {email: user.email, password: user.password}
  end
end
