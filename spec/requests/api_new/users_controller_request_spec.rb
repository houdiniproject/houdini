# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe ApiNew::UsersController, type: :request do


	context 'for unlogged in user' do
		it 'returns unauthorized when not logged in' do
			get "/api_new/users/current"
			expect(response).to have_http_status(:unauthorized)
		end
	end

	context 'for a nonprofit admin' do 

		let(:user) {create(:user_base, roles:[build(:role_base, :as_nonprofit_admin) ])}


		subject(:body) { response.body}
		before do
			sign_in user
			get "/api_new/users/current"
		end

		it {
			expect(response).to have_http_status(:success)
		}

		it {
			is_expected.to include_json(
				object: 'user', 
				is_super_admin: false,
				roles: [
					{
						host: Nonprofit.first.to_houid
					}
			])
		}
			
	end

	context 'for a nonprofit associate' do 
		let(:user) {create(:user_as_nonprofit_associate)}

		subject(:body) { response.body}
		before do
			sign_in user
			get "/api_new/users/current"
		end

		it {
			expect(response).to have_http_status(:success)
		}

		it {
			is_expected.to include_json(
				object: 'user', 
				is_super_admin: false,
				roles: []
			)
		}
			
	end

	context "for super admin" do
		let(:user) {create(:user_as_super_admin )}

		subject(:body) { response.body}
		before do
			sign_in user
			get "/api_new/users/current"
		end

		it {
			expect(response).to have_http_status(:success)
		}

		it {
			is_expected.to include_json(
				object: 'user', 
				is_super_admin: true,
				roles: []
			)
		}
	end

	context 'test using basic auth (testing that Devise.http_authenticatable works)' do
		let(:user) {create(:user_as_nonprofit_associate, password: 'valid_password')}


		
		subject(:body) { response.body}

		describe "with correct password" do
			before do
				get "/api_new/users/current", nil, {authorization: "Basic #{Base64.encode64("#{user.email}:valid_password")}"}
			end

			it {
				expect(response).to have_http_status(:success)
			}
		end

		describe "with incorrect password" do
			before do
				get "/api_new/users/current", nil, {authorization: "Basic #{Base64.encode64("#{user.email}:BAD_PASSWORD")}"}
			end

			it {
				expect(response).to have_http_status(:unauthorized)
			}
		end
	end
		


  

end

