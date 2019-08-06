# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscellaneousNpInfo < ApplicationRecord
  # :donate_again_url,
  # :change_amount_message

  belongs_to :nonprofit
end
