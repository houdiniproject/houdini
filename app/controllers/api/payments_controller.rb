# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a subtransactions payments
class Api::PaymentsController < Api::ApiController
	include Controllers::Api::Transaction::Current
	include Controllers::Nonprofit::Authorization
	before_action :authenticate_nonprofit_user!

	def index
		@subtransaction_payments = current_subtransaction.subtransaction_payments.order('created DESC').page(params[:page]).per(params[:per])
	end
	
	def show
		@subtransaction_payment = current_payment
	end

	private
	def current_subtransaction
		current_transaction.subtransaction
	end

	def current_payment
		current_subtransaction.subtransaction_payments.where('paymentable_id = ?', params[:id])
	end
end
