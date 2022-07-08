# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

json.partial! 'users/sign_in'

json.innerProps do 
	json.administeredNonprofit do 
		json.(administered_nonprofit, :id, :name)
	end if administered_nonprofit

	json.currentUser do
		json.(current_user, :id)

		json.profile do
			json.(current_user.profile, :id, :name)
		end if current_user.profile
	end if current_user

	json.logo do
		json.url Houdini.general.logo
		json.alt Houdini.general.name
	end
end