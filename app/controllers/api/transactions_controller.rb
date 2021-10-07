# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

# A controller for interacting with a nonprofit's supporters
class Api::TransactionsController < Api::ApiController
	include Controllers::Nonprofit::Current
	include Controllers::Nonprofit::Authorization
	before_action :authenticate_nonprofit_user!

	# Gets the nonprofits supporters
	# If not logged in, causes a 401 error
	def index
		@transactions = current_nonprofit.transactions.order('created DESC').page(params[:page]).per(params[:per])
	end

	# Gets the a single nonprofit supporter
	# If not logged in, causes a 401 error
	def show
		@transaction = current_nonprofit.transactions.find(params[:id])
	end
end
