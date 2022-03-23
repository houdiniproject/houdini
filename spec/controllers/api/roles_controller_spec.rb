# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe Api::RolesController, type: :controller do
	describe 'authorization' do
		it 'get' do
			expect(response.status).to eq 200
		end
	end
end
