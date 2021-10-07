# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe '/api/supporter_addresses/index.json.jbuilder', type: :view do
	subject(:json) do
		assign(
			:supporter_addresses,
			supporter_with_fv_poverty
				.nonprofit
				.supporters
				.where(id: supporter_with_fv_poverty.id).order('id DESC').page
		)
		render
		JSON.parse(rendered)
	end

	let(:supporter_with_fv_poverty) { create(:supporter_with_fv_poverty) }

	it {
		expect(json['data'].count).to eq 1
	}

	it { is_expected.to include('first_page' => true) }
	it { is_expected.to include('last_page' =>  true) }
	it { is_expected.to include('current_page' => 1) }
	it { is_expected.to include('requested_size' => 25) }
	it { is_expected.to include('total_count' => 1) }

	describe 'details of the first item' do
		subject(:first) do
			json['data'][0]
		end

		let(:supporter) { supporter_with_fv_poverty }
		let(:supporter_address) { supporter }
		let(:nonprofit) { supporter.nonprofit }

		it {
			is_expected.to include('object' => 'supporter_address')
		}

		it {
			is_expected.to include('id' => supporter_address.id)
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('supporter' => supporter.id)
		}

		it {
			is_expected.to include('address' => supporter_address.address)
		}

		it {
			is_expected.to include('city' => supporter_address.city)
		}

		it {
			is_expected.to include('state_code' => supporter_address.state_code)
		}

		it {
			is_expected.to include('country' => supporter_address.country)
		}

		it {
			is_expected.to include('zip_code' => supporter_address.zip_code)
		}

		it {
			is_expected.to include('url' =>
				a_string_matching(
					%r{http://test\.host/api/nonprofits/#{nonprofit.id}/supporters/#{supporter.id}/supporter_addresses/#{supporter_address.id}} # rubocop:disable Layout/LineLength
				))
		}
	end
end
