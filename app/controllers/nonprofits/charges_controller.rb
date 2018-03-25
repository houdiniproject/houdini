module Nonprofits
	class ChargesController < ApplicationController
		include NonprofitHelper

		before_filter :authenticate_nonprofit_user!, only: :index

		# get /nonprofit/:nonprofit_id/charges
		def index
			redirect_to controller: :payments, action: :index
		end # def index

	end
end
