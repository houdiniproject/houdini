# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
	class RefundsController < ApplicationController
		include Controllers::NonprofitHelper

		before_filter :authenticate_nonprofit_user!

		# post /charges/:charge_id/refunds
		def create
      charge = Qx.select("*").from("charges").where(id: params[:charge_id]).execute.first
			params[:refund][:user_id] = current_user.id
      render_json{ InsertRefunds.with_stripe(charge, params['refund']) }
		end

		def index
			charge = current_nonprofit.charges.find(params[:charge_id])
			@refunds = charge.refunds
		end
	end
end

