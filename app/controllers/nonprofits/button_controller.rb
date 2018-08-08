# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
class ButtonController < ApplicationController
	include Controllers::NonprofitHelper


	before_filter :authenticate_user!


	def send_code
		NonprofitMailer.button_code(current_nonprofit, params[:to_email], params[:to_name], params[:from_email], params[:message], params[:code]).deliver
		render json: {}, status: 200
	end

	def basic
		@nonprofit = current_nonprofit
	end

	def guided
		@nonprofit = current_nonprofit
	end

	def advanced
		@nonprofit = current_nonprofit
	end
	
end
end
