# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe 'api/payments/show.json.jbuilder', type: :view do
	def base_path(nonprofit_id, transaction_id)
		"/api/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}"
	end

	def subtransaction_path(nonprofit_id, transaction_id)
		"/api/nonprofits/#{nonprofit_id}/transactions/#{transaction_id}/subtransaction"
	end

	def base_url(nonprofit_id, transaction_id)
		"http://test.host#{base_path(nonprofit_id, transaction_id)}"
	end

	def subtransaction_url(nonprofit_id, transaction_id)
		"http://test.host#{subtransaction_path(nonprofit_id, transaction_id)}"
	end

	def payment_path(nonprofit_id, transaction_id, payment_id)
		"#{subtransaction_path(nonprofit_id, transaction_id)}/payments/#{payment_id}"
	end

	def payment_url(nonprofit_id, transaction_id, payment_id)
		"http://test.host#{payment_path(nonprofit_id, transaction_id, payment_id)}"
	end

	subject(:json) do
		view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
		assign(:payment, payment)
		render
		JSON.parse(rendered)
	end

	let(:transaction) { create(:transaction_for_donation) }
	let(:subtransaction) { transaction.subtransaction }
	let(:payment) { subtransaction.payments.first }
	let(:supporter) { payment.supporter }
	let(:nonprofit) { payment.nonprofit }

	include_context 'with json results for first payment on transaction_for_donation'
end
