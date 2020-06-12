# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module ProfilesHelper
  def get_shortened_name(name)
    if name
      name.length > 18 ? name[0..18] + '...' : name
    else
      'Your Account'
    end
  end
end
