# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketPurchase < ApplicationRecord
  include Model::TrxAssignable
  setup_houid :tktpur

  before_create :set_original_discount

  belongs_to :event_discount
  belongs_to :event

  has_many :ticket_to_legacy_tickets

  validates :event, presence: true

  def to_id
    ::Jbuilder.new do |json|
      json.id id
      json.object "ticket_purchase"
      json.type "trx_assignment"
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.type "trx_assignment"

      if original_discount
        json.original_discount do
          json.percent original_discount
        end
      end

      json.amount do
        json.cents amount
        json.currency nonprofit.currency
      end

      json.add_builder_expansion :event, :event_discount, :nonprofit, :supporter
      json.add_builder_expansion :ticket_to_legacy_tickets, enum_type: :expandable, json_attribute: "tickets"
      json.add_builder_expansion :trx, json_attribute: :transaction
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:ticket_purchase_created, to_event("ticket_purchase.created", :event, :nonprofit, :supporter, :trx, :event_discount, :ticket_to_legacy_tickets).attributes!)
    Houdini.event_publisher.announce(:trx_assignment_created, to_event("trx_assignment.created", :event, :nonprofit, :supporter, :trx, :event_discount, :ticket_to_legacy_tickets).attributes!)
  end

  private

  def set_original_discount
    event_discount.nil? ? 0 : event_discount.percent
  end
end
