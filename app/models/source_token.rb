# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SourceToken < ApplicationRecord
  self.primary_key = :token
  # :expiration,
  # :token,
  # :max_uses,
  # :total_uses
  belongs_to :tokenizable, polymorphic: true
  belongs_to :event
end
