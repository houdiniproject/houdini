# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscount < ApplicationRecord
  belongs_to :event, required: true
  has_many :tickets

  validates_presence_of :code, :name, :percent

  validates :percent, numericality: {greater_than: 0, less_than_or_equal_to: 100}
end
