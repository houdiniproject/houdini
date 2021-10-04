# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'
describe 'GoodJob protection' do
	let(:user) { create(:user) }

	describe 'when it is a super_admin' do
		it 'shows the good job dashboard' do
			user.roles.create(name: 'super_admin')
			sign_in user
			get('/good_job')
			expect(response).to have_http_status(:success)
		end
	end

	describe 'when not logged in' do
		it 'is redirected to log in page' do
			get('/good_job')
			expect(response).to have_http_status(:redirect)
		end
	end

	describe 'when logged in but is not super_admin' do
		it 'raises RoutingError' do
			sign_in user
			expect { get('/good_job') }.to raise_error(ActionController::RoutingError)
		end
	end
end
