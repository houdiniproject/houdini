# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
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
