# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module ProfilesHelper
  def get_shortened_name(name)
    if name
      name.length > 18 ? name[0..18] + '...' : name
    else
      'Your Account'
    end
  end
end
