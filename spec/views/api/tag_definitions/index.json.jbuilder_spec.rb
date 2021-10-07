# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe '/api/tag_definitions/index.json.jbuilder', type: :view do
	subject(:json) do
		assign(:tag_definitions, Kaminari.paginate_array([tag_definition]).page)
		render
		JSON.parse(rendered)
	end

	let(:tag_definition) { create(:tag_definition_with_nonprofit) }
	let(:nonprofit) { tag_definition.nonprofit }

	it { expect(json['data'].count).to eq 1 }

	describe 'details of the first item' do
		subject(:first) do
			json['data'].first
		end

		it {
			is_expected.to include('object' => 'tag_definition')
		}

		it {
			is_expected.to include('id' => tag_definition.id)
		}

		it {
			is_expected.to include('name' => 'Tag Name')
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('url' =>
				a_string_matching(
					%r{http://test\.host/api/nonprofits/#{nonprofit.id}/tag_definitions/#{tag_definition.id}}
				))
		}
	end

	describe 'paging' do
		subject(:json) do
			tag_definition
			(0..5).each do |i|
				create(:tag_definition_with_nonprofit,
											nonprofit: nonprofit,
											name: i)
			end
			assign(:tag_definitions, nonprofit.tag_masters.order('id DESC').page.per(5))
			render
			JSON.parse(rendered)
		end

		it { is_expected.to include('data' => have_attributes(count: 5)) }
		it { is_expected.to include('first_page' => true) }
		it { is_expected.to include('last_page' =>  false) }
		it { is_expected.to include('current_page' => 1) }
		it { is_expected.to include('requested_size' => 5) }
		it { is_expected.to include('total_count' => 7) }
	end
end
