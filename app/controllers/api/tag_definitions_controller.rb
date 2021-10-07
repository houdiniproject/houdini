# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

# A controller for interacting with a nonprofit's custom field definition
class Api::TagDefinitionsController < Api::ApiController
	include Controllers::Nonprofit::Current
	include Controllers::Nonprofit::Authorization
	before_action :authenticate_nonprofit_user!

	# Gets the nonprofits custom field definitions
	# If not logged in, causes a 401 error
	def index
		@tag_definitions =
			current_nonprofit
			.tag_masters
			.order('id DESC')
			.page(params[:page])
			.per(params[:per])
	end

	# Gets a single custom field definition
	# If not logged in, causes a 401 error
	def show
		@tag_definition = current_nonprofit.tag_masters.find(params[:id])
	end
end
