# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe '/api/nonprofits/show.json.jbuilder', type: :view do
	subject(:json) do
		assign(:nonprofit, nonprofit)
		render
		JSON.parse(rendered)
	end

	let(:nonprofit) { create(:fv_poverty) }

	it {
		is_expected.to include('id' => nonprofit.id)
	}

	it {
		is_expected.to include('name' => nonprofit.name)
	}

	it {
		is_expected.to include('object' => 'nonprofit')
	}
end
