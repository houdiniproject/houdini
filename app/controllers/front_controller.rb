# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class FrontController < ApplicationController



  def index
		flash.keep
		if current_role?([:nonprofit_admin,:nonprofit_associate])
			redirect_to NonprofitPath.dashboard(administered_nonprofit)
		elsif current_user
			redirect_to '/profiles/' + current_user.profile.id.to_s
		else
			respond_to { |format| format.html }
		end
	end

end
