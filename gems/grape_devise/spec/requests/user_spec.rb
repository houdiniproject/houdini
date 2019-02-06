require 'spec_helper'
require 'warden/test/helpers'

RSpec.describe API, :type => :request do
  include Warden::Test::Helpers

  let(:user) { build(:user) }

  after{ Warden.test_reset! }

  it "should return the current user" do
    login_as user, scope: :user

    get "/me"

    response.body.should eq(user.to_json)
  end

  it "should return an error if not logged in" do
    login_as nil, scope: :user

    get "/me"

    response.code.should eq("401")
  end

  it "should return true if logged in" do
    login_as user, scope: :user

    get "/authorized"

    response.body.should eq("true")
  end

  it "should return false if logged out" do
    login_as nil, scope: :user

    get "/authorized"

    response.body.should eq("false")
  end

  it "should log in the user" do
    User.stub :find_for_database_authentication do
      user
    end
    post "/signin", { user: { email: user.email, password: user.password } }

    response.code.should eq("201")
  end

end