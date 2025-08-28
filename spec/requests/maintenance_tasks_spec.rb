# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "MaintenanceTasks", type: :request do
  it "allows a super user to visit" do
    sign_in create(:user_as_super_admin)
    get '/maintenance_tasks/'

    expect(response).to have_http_status(:success)
  end

  [:user_as_nonprofit_associate, :user_as_nonprofit_admin, :automated_user, :user].each do |factory|
    it "prevents a #{factory.to_s} from visiting" do
      sign_in create(factory)
      get '/maintenance_tasks/'

      expect(response).to redirect_to( '/')
    end
  end

  it "prevents an unknown user from visiting" do
    get '/maintenance_tasks/'

    expect(response).to redirect_to( '/users/sign_in' )
  end
end
