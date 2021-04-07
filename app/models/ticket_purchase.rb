# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class TicketPurchase < ApplicationRecord
  include Model::TrxAssignable
  setup_houid :tktpur

  add_builder_expansion :event, :event_discount
  
  
  before_create :set_original_discount

  belongs_to :event_discount
  belongs_to :event
  
  has_many :ticket_to_legacy_tickets

  validates :event, presence: true

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.original_discount do
        json.percent original_discount
      end if original_discount

      json.amount do
        json.cents amount
        json.currency nonprofit.currency
      end


      if expand.include? :tickets
        json.tickets ticket_to_legacy_tickets do |i|
          i.to_builder.attributes!
        end
      else
        json.tickets ticket_to_legacy_tickets.pluck(:id)
      end
    end
  end

  def publish_created
    Houdini.event_publisher.announce(:ticket_purchase_created, to_event('ticket_purchase.created', :event, :nonprofit, :supporter, :trx, :event_discount).attributes!)
  end

  private
  def set_original_discount
    original_discount = event_discount.nil? ? 0 : event_discount.percent
  end
end
