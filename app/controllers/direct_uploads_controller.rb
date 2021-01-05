# frozen_string_literal: true

#
class DirectUploadsController < ActiveStorage::DirectUploadsController
	include Controllers::Nonprofit::Authorization
	skip_before_action :verify_authenticity_token, only: [:create]
	before_action  do
		authenticate_user!("You must be logged in to use this", :json)
	end
end