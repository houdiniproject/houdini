# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class TicketPurchase < ApplicationRecord
  include Model::Houidable
  include Model::Jbuilder
  setup_houid :tktpur

  add_builder_expansion :event, :nonprofit, :supporter
  add_builder_expansion :trx, 
    json_attrib: :transaction
  
  add_builder_expansion :event_discount,
    to_id: -> (model) { model.event_discount&.id },
    to_expand: -> (model) { model.event_discount&.to_builder }
  
  before_create :set_original_discount

  belongs_to :event_discount
  belongs_to :event
  has_one :transaction_assignment, as: :assignable
  has_one :trx, through: :transaction_assignment
  has_one :supporter, through: :trx
  has_one :nonprofit, through: :supporter
  
  has_many :ticket_to_legacy_tickets

  validates :event, presence: true

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.(self, :id)
      json.object 'ticket_purchase'
      json.original_discount do
        json.percent original_discount
      end if original_discount

      json.amount do
        json.value_in_cents amount
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

  private
  def set_original_discount
    original_discount = event_discount.nil? ? 0 : event_discount.percent
  end
end
