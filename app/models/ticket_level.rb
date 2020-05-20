# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TicketLevel < ApplicationRecord
  # :amount, #integer
  # :amount_dollars, #accessor, string
  # :name, #string
  # :description, #text
  # :quantity, #integer
  # :deleted, #bool for soft delete
  # :event_id,
  # :admin_only, #bool, only admins can create tickets for this level
  # :limit, #int: for limiting the number of tickets to be sold
  # :order #int: order in which to be displayed

  attr_accessor :amount_dollars

  has_many :tickets
  belongs_to :event

  validates :name, presence: true
  validates :event_id, presence: true

  scope :not_deleted, -> { where(deleted: [false, nil]) }

  before_validation do
    self.amount = Format::Currency.dollars_to_cents(amount_dollars) if amount_dollars.present?
    self.amount = 0 if amount.nil?
  end
end
