# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api/transactions/index.json.jbuilder', type: :view do
	subject(:json) do
		view.lookup_context.prefixes = view.lookup_context.prefixes.drop(1)
		assign(:transactions, Kaminari.paginate_array([transaction]).page)
		assign(:__expand,
									Controllers::Api::JbuilderExpansions::ExpansionRequest.new('supporter', 'transaction_assignments', 'payments',
																																																																				'subtransaction.payments'))
		render
		rendered
	end

	around do |ex|
		Timecop.freeze(2020, 5, 4) do
			ex.run
		end
	end

	include Controllers::Api::JbuilderExpansions
	def base_path(nonprofit_id, transaction_id)
		"/api/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}"
	end

	def base_url(nonprofit_id, transaction_id)
		"http://test.host#{base_path(nonprofit_id, transaction_id)}"
	end

	let(:transaction) { create(:transaction_for_donation) }
	let(:supporter) { transaction.supporter }
	let(:nonprofit) { transaction.nonprofit }

	it {
		is_expected.to include_json(
			'first_page' => true,
			last_page: true,
			current_page: 1,
			requested_size: 25,
			total_count: 1,
			data: [
				attributes_for(:trx,
																			nonprofit: nonprofit.id,
																			supporter: attributes_for(
																				:supporter_expectation,
																				id: supporter.id
																			),
																			id: transaction.id,
																			amount_cents: 4000,
																			subtransaction: attributes_for(
																				:subtransaction_expectation,
																				:offline_transaction,
																				gross_amount_cents: 4000,
																				payments: [
																					attributes_for(:payment_expectation,
																																				:offiline_transaction_charge,
																																				gross_amount_cents: 4000,
																																				fee_total_cents: 0)
																				]
																			),
																			payments: [
																				attributes_for(:payment_expectation,
																																			:offline_transaction_charge,
																																			gross_amount_cents: 4000,
																																			fee_total_cents: 0)
																			],
																			transaction_assignments: [
																				attributes_for(:trx_assignment_expectation,
																																			:donation,
																																			amount_cents: 4000,
																																			designation: 'Designation 1')
																			])
			]
		)
	}
end
