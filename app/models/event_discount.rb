# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EventDiscount < ApplicationRecord
  belongs_to :event, optional: false
  has_many :tickets

  validates :code, :name, :percent, presence: true

  validates :percent, numericality: {greater_than: 0, less_than_or_equal_to: 100}
end
