# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

describe Users::SessionsController, type: :request do
	describe 'POST /users/sign_in' do
		context 'successful login' do 
			let(:user) { create(:user)}
			let(:json) { JSON::parse(response.body)}
		
			
			before {
				headers = { "ACCEPT" => "application/json" }
				post '/users/sign_in', params: {user: {email: user.email, password: user.password}}
			}

			it {
				expect(response).to have_http_status(200)
			}

			it {
				expect(response).to have_attributes(content_type: starting_with('application/json'))
			}

			it {
				expect(json).to eq({
					'id' => user.id,
					'object' => 'user'
				})
			}
		end

		
	end
end
