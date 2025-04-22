# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Ticket < ApplicationRecord
  # :note,
  # :event_discount,
  # :event_discount_id

  belongs_to :event_discount
  belongs_to :supporter
  belongs_to :profile
  belongs_to :ticket_level
  belongs_to :event
  belongs_to :charge
  belongs_to :card
  belongs_to :payment
  belongs_to :source_token
  has_one :nonprofit, through: :event
  has_many :activities, as: :attachment, dependent: :destroy
  has_many :ticket_to_legacy_tickets

  def related_tickets
    payment.tickets.where.not(id: id)
  end
end
