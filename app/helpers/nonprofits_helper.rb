# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module NonprofitsHelper

	def managed_npo_card_json
		if current_user
			if params[:nonprofit_id] && current_role?(:super_admin)
				raw(Nonprofit.find(params[:nonprofit_id]).active_card.to_json)
			elsif administered_nonprofit && administered_nonprofit.active_card
				raw(administered_nonprofit.active_card.to_json)
			end
		else
			'undefined'
		end
	end

end
