# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class MiscellaneousNpInfo < ApplicationRecord
  # :donate_again_url,
  # :change_amount_message

  belongs_to :nonprofit
end
