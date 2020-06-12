# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Tracking < ApplicationRecord
  # :utm_campaign,
  # :utm_content,
  # :utm_medium,
  # :utm_source

  belongs_to :donation
end
