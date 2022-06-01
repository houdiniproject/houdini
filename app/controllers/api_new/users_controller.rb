# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ApiNew::UsersController < ApiNew::ApiController
	include Controllers::User::Authorization

	before_action :authenticate_user!

	# Returns the current user as JSON
	# If not logged in, causes a 401 error
	def current
		@user = current_user
	end
end
