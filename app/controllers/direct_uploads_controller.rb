# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class DirectUploadsController < ActiveStorage::DirectUploadsController
	include Controllers::Nonprofit::Authorization
	skip_before_action :verify_authenticity_token, only: [:create]
	before_action  :authenticate_user_with_json!

private
	def authenticate_confirmed_user_with_json!
		authenticate_confirmed_user!("You must be logged in to use this", :json)
	end
end