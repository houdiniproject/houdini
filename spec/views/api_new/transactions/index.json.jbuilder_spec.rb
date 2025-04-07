# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api_new/transactions/index.json.jbuilder', type: :view do

	around do |ex|
		Timecop.freeze(2020, 5, 4) do
			ex.run
		end
	end

	include Controllers::ApiNew::JbuilderExpansions
	def base_path(nonprofit_id, transaction_id)
		"/api_new/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}"
	end

	def base_url(nonprofit_id, transaction_id)
		"http://test.host#{base_path(nonprofit_id, transaction_id)}"
	end

	subject(:json) do
		view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2) # Rails does weird things in view specs when you use a route namespace
		assign(:transactions, Kaminari.paginate_array([transaction]).page)
		assign(:__expand, Controllers::ApiNew::JbuilderExpansions::ExpansionTree.new('supporter', 'transaction_assignments', 'payments', 'subtransaction.payments'))
		render
		rendered
	end

	let(:transaction) { create(:transaction_for_offline_donation) }
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
					nonprofit: nonprofit.houid,
					supporter: attributes_for(
						:supporter_expectation,
						id: supporter.houid
					),
					id: transaction.houid,
					amount_cents: 4000,
					subtransaction: attributes_for(
						:subtransaction_expectation, 
						:offline_transaction, 
						gross_amount_cents: 4000,
						net_amount_cents: 4000,
						payments: [
							attributes_for(:payment_expectation, 
							:offline_transaction_charge, 
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
							amount_cents:4000,
							designation: "Designation 1"
							)
					]
				)
			]
		)
	}

	# describe 'paging' do
	# 	subject(:json) do
	# 		transaction
	# 		(0..5).each do |_i|
	# 			create(
	# 				:transaction,
	# 				nonprofit: transaction.nonprofit,
	# 				supporter: transaction.supporter
	# 			)
	# 		end
	# 		assign(:transactions, nonprofit.transactions.order('created DESC').page.per(5))
	# 		render
	# 		JSON.parse(rendered)
	# 	end

	# 	it { is_expected.to include('data' => have_attributes(count: 5)) }
	# 	it { is_expected.to include('first_page' => true) }
	# 	it { is_expected.to include('last_page' =>  false) }
	# 	it { is_expected.to include('current_page' => 1) }
	# 	it { is_expected.to include('requested_size' => 5) }
	# 	it { is_expected.to include('total_count' => 7) }
	# end
end
