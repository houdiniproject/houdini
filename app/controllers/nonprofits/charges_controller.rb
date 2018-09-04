# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
	class ChargesController < ApplicationController
		include Controllers::NonprofitHelper

		before_filter :authenticate_nonprofit_user!, only: :index

		# get /nonprofit/:nonprofit_id/charges
		def index
			redirect_to controller: :payments, action: :index
		end # def index

	end
end
