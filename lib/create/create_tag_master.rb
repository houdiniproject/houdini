# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module CreateTagMaster
  def self.create(nonprofit, params)
    tag_master = nonprofit.tag_masters.create(params)
    tag_master
  end
end
