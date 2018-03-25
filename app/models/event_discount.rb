class EventDiscount < ActiveRecord::Base
  attr_accessible \
    :code,
    :event_id,
    :name,
    :percent

  belongs_to :event
  has_many :tickets

end
