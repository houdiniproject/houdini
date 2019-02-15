require "grape_devise"

class API < Grape::API
  format :json

  get "me" do
    authenticate_user!
    current_user
  end

  get "authorized" do
    user_signed_in?
  end

  post "signin" do
    authenticate_user!
  end
end