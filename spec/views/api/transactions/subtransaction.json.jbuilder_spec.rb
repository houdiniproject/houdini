# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api/transactions/subtransaction.json.jbuilder', type: :view do
	def base_path(nonprofit_id, transaction_id)
		"/api/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}"
	end

	def base_url(nonprofit_id, transaction_id)
		"http://test.host#{base_path(nonprofit_id, transaction_id)}"
	end
	subject(:json) do
		assign(:subtransaction, transaction.subtransaction)
		render
		JSON.parse(rendered)
	end

	let(:transaction) { create(:transaction_for_donation) }
	let(:supporter) { transaction.supporter }
	let(:id) { json['id'] }
	let(:nonprofit) { transaction.nonprofit }

	it 'has payments' do

		result = json

		byebug

	end
	
end
