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
		assign(:transactions, [transaction])
		render
		JSON.parse(rendered)
	end

	let(:transaction) { create(:transaction_for_donation) }
	let(:supporter) { transaction.supporter }
	let(:nonprofit) { transaction.nonprofit }

	it { expect(json.count).to eq 1 }

	describe 'details of the first item' do
		subject(:first) do
			json.first
		end

		include_context 'with json results for transaction_for_donation'
	end
end
