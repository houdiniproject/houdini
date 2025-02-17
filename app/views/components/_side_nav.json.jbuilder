# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE

json.partial! "users/sign_in"

json.innerProps do
  if administered_nonprofit
    json.administeredNonprofit do
      json.partial! "app_data/nonprofit", nonprofit: administered_nonprofit
    end
  end

  if current_user
    json.currentUser do
      json.partial! "app_data/user_with_profile_as_child", user: current_user
    end
  end

  json.logo do
    json.url Houdini.general.logo
    json.alt Houdini.general.name
  end
end
