# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscount < ApplicationRecord
  #TODO
  # attr_accessible \
  #   :code,
  #   :event_id,
  #   :name,
  #   :percent

  belongs_to :event
  has_many :tickets

end
