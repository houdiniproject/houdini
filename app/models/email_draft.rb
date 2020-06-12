# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class EmailDraft < ApplicationRecord
  # :nonprofit, :nonprofit_id,
  # :name,
  # :deleted,
  # :value,
  # :created_at

  belongs_to :nonprofit

  scope :not_deleted, -> { where(deleted: [nil, false]) }
end
