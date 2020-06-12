# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class DateTime
  def nsec
    (sec_fraction * 1_000_000_000).to_i
  end
end
