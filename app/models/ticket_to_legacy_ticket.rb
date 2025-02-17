# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketToLegacyTicket < ApplicationRecord
  include Model::Houidable
  include Model::Jbuilder
  include Model::Eventable

  belongs_to :ticket_purchase
  belongs_to :ticket

  has_one :ticket_level, through: :ticket
  has_one :event, through: :ticket_purchase
  has_one :event_discount, through: :ticket_purchase
  has_one :supporter, through: :ticket_purchase
  has_one :nonprofit, through: :event

  delegate :original_discount, to: :ticket_purchase
  delegate :checked_in, :deleted, :note, to: :ticket

  setup_houid :tkt

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :checked_in, :deleted, :note)
      json.object "ticket"

      json.amount do
        json.cents amount
        json.currency nonprofit.currency
      end

      if original_discount
        json.original_discount do
          json.percent original_discount
        end
      end

      json.add_builder_expansion :ticket_purchase, :ticket_level, :supporter, :event, :nonprofit, :event_discount
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:ticket_created, to_event("ticket.created",
      :ticket_purchase,
      :ticket_level,
      :supporter,
      :event,
      :nonprofit,
      :event_discount).attributes!)
  end

  def publish_updated
    Houdini.event_publisher.announce(:ticket_updated, to_event("ticket.updated",
      :ticket_purchase,
      :ticket_level,
      :supporter,
      :event,
      :nonprofit,
      :event_discount).attributes!)
  end

  def publish_deleted
    Houdini.event_publisher.announce(:ticket_deleted, to_event("ticket.deleted",
      :ticket_purchase,
      :ticket_level,
      :supporter,
      :event,
      :nonprofit,
      :event_discount).attributes!)
  end
end
