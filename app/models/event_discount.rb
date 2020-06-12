# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class EventDiscount < ApplicationRecord
  # :code,
  # :event_id,
  # :name,
  # :percent

  belongs_to :event
  has_many :tickets
end
