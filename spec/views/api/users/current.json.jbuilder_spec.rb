# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe '/api/users/current.json.jbuilder', type: :view do
	subject(:json) do
		assign(:user, create(:user))
		render
		JSON.parse(rendered)
	end

	it {
		is_expected.to include('id' => kind_of(Numeric))
	}

	it {
		is_expected.to include('object' => 'user')
	}
end
