# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Api::UsersController < Api::ApiController
	include Controllers::User::Authorization

	before_action :authenticate_user_with_json!

	def current
		render locals: { user: current_user }
	end
end
