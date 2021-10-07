# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'rails_helper'

RSpec.describe '/api/transactions/index.json.jbuilder', type: :view do
	def base_path(nonprofit_id, transaction_id)
		"/api/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}"
	end

	def base_url(nonprofit_id, transaction_id)
		"http://test.host#{base_path(nonprofit_id, transaction_id)}"
	end

	subject(:json) do
		assign(:transactions, Kaminari.paginate_array([transaction]).page)
		render
		JSON.parse(rendered)
	end

	let(:transaction) { create(:transaction_for_donation) }
	let(:supporter) { transaction.supporter }
	let(:nonprofit) { transaction.nonprofit }

	it { expect(json['data'].count).to eq 1 }

	describe 'details of the first item' do
		subject(:first) do
			json['data'].first
		end

		include_context 'with json results for transaction_for_donation'
	end

	describe 'paging' do
		subject(:json) do
			transaction
			(0..5).each do |_i|
				create(
					:transaction,
					nonprofit: transaction.nonprofit,
					supporter: transaction.supporter
				)
			end
			assign(:transactions, nonprofit.transactions.order('created DESC').page.per(5))
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
