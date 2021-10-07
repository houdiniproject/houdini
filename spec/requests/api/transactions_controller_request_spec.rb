# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe Api::TransactionsController, type: :request do
	let(:nonprofit) { transaction_for_donation.nonprofit }
	let(:user) { create(:user) }
	let(:supporter) { transaction_for_donation.supporter }

	let(:transaction_for_donation) do
		create(:transaction_for_donation)
	end

	before do
		transaction_for_donation
	end

	def index_base_path(nonprofit_id)
		"/api/nonprofits/#{nonprofit_id}/transactions"
	end

	def index_base_url(nonprofit_id, _event_id)
		"http://www.example.com#{index_base_path(nonprofit_id)}"
	end

	describe 'GET /:id' do
		let(:transaction) { transaction_for_donation }

		def base_path(nonprofit_id, transaction_id)
			index_base_path(nonprofit_id) + "/#{transaction_id}"
		end

		def base_url(nonprofit_id, transaction_id)
			"http://www.example.com#{base_path(nonprofit_id, transaction_id)}"
		end

		context 'with nonprofit user' do
			subject do
				JSON.parse(response.body)
			end

			before do
				user.roles.create(name: 'nonprofit_associate', host: nonprofit)
				sign_in user
				get base_path(
					nonprofit.id,
					transaction.id
				)
			end

			it {
				expect(response).to have_http_status(:success)
			}

			include_context 'with json results for transaction_for_donation'
		end

		context 'with no user' do
			it 'returns unauthorized' do
				get base_path(
					nonprofit.id,
					transaction.id
				)
				expect(response).to have_http_status(:unauthorized)
			end
		end
	end

	describe 'GET /' do
		context 'with nonprofit user' do
			subject(:json) do
				JSON.parse(response.body)
			end

			before do
				user.roles.create(name: 'nonprofit_associate', host: nonprofit)
				sign_in user
				get index_base_path(nonprofit.id)
			end

			it {
				expect(response).to have_http_status(:success)
			}

			it { expect(json['data'].count).to eq 1 }

			describe 'for transaction_for_donation' do
				subject(:first) do
					json['data'].first
				end

				def base_path(nonprofit_id, transaction_id)
					index_base_path(nonprofit_id) + "/#{transaction_id}"
				end

				let(:transaction) { transaction_for_donation }

				def base_url(nonprofit_id, transaction_id)
					"http://www.example.com#{base_path(nonprofit_id, transaction_id)}"
				end
				include_context 'with json results for transaction_for_donation'
			end

			it { is_expected.to include('first_page' => true) }
			it { is_expected.to include('last_page' =>  true) }
			it { is_expected.to include('current_page' => 1) }
			it { is_expected.to include('requested_size' => 25) }
			it { is_expected.to include('total_count' => 1) }
		end

		context 'with no user' do
			it 'returns unauthorized' do
				get index_base_path(nonprofit.id)
				expect(response).to have_http_status(:unauthorized)
			end
		end
	end
end
