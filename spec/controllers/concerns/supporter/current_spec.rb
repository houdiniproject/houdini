#frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

describe 'Controllers::Supporter::Current', type: :controller do
	let(:nonprofit) { force_create(:nm_justice)}
	let(:supporter) { force_create(:supporter)}

	class TestController < ApplicationController
		include Controllers::User::Authorization
		include Controllers::Supporter::Current
	end
	
	

	controller(TestController) do 
		def index
			render json: {
				supporter: "supporters: #{current_supporter.id}", 
				nonprofit: "nonprofit: #{current_nonprofit.id}"
			}
		end
	end
	
	it 'handles situations where we use id' do
		nonprofit
		supporter
		get :index, params: {nonprofit_id: nonprofit.id, id: supporter.id}
		expect(JSON::parse(response.body)).to eq({ 
			'supporter' => "supporters: #{supporter.id}", 
			'nonprofit' => "nonprofit: #{nonprofit.id}"
		})
	end

	it 'handles situations where we use supporter_id' do 
		nonprofit
		supporter

		get :index, params: {nonprofit_id: nonprofit.id, supporter_id: supporter.id, id: 1}
		expect(JSON::parse(response.body)).to eq({ 
			'supporter' => "supporters: #{supporter.id}", 
			'nonprofit' => "nonprofit: #{nonprofit.id}"
		})
	end
end