# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Export < ApplicationRecord
  # :exception,
  # :nonprofit,
  # :status,
  # :user,
  # :export_type,
  # :parameters,
  # :ended,
  # :url,
  # :user_id,
  # :nonprofit_id
  
  STATUS = %w[queued started completed failed].freeze

  belongs_to :nonprofit
  belongs_to :user

  validates :user, presence: true
end
