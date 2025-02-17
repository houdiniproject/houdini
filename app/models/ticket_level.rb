# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketLevel < ApplicationRecord
  include Model::Jbuilder
  include Model::Eventable
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

  # TODO replace with Discard gem
  define_model_callbacks :discard

  after_discard :publish_delete

  after_create :publish_create
  after_update :publish_updated

  attr_accessor :amount_dollars

  has_many :tickets
  belongs_to :event
  has_one :nonprofit, through: :event

  validates :name, presence: true
  validates :event_id, presence: true

  validate :amount_hasnt_changed_if_has_tickets, on: :update

  scope :not_deleted, -> { where(deleted: [false, nil]) }

  # has_many didn't work here, don't know why offhand.
  def event_discounts
    event.event_discounts
  end

  before_validation do
    self.amount = Format::Currency.dollars_to_cents(amount_dollars) if amount_dollars.present?
    self.amount = 0 if amount.nil?
  end

  def amount_as_money
    Amount.new(amount || 0, nonprofit.currency)
  end

  # TODO replace with discard gem
  def discard!
    run_callbacks(:discard) do
      self.deleted = true
      save!
    end
  end

  def to_builder(*expand)
    init_builder(*expand) do |json|
      json.call(self, :name, :deleted, :order, :limit, :description)
      json.amount do
        json.cents amount_as_money.cents
        json.currency amount_as_money.currency
      end
      json.available_to admin_only ? "admins" : "everyone"

      json.add_builder_expansion :nonprofit, :event

      json.add_builder_expansion :event_discounts, enum_type: :expandable
    end
  end

  private

  def publish_create
    Houdini.event_publisher.announce(:ticket_level_created, to_event("ticket_level.created", :event, :nonprofit, :event_discounts).attributes!)
  end

  def publish_updated
    # we don't run update when we've really just discarded
    unless deleted
      Houdini.event_publisher.announce(:ticket_level_updated, to_event("ticket_level.updated", :event, :nonprofit, :event_discounts).attributes!)
    end
  end

  def publish_delete
    Houdini.event_publisher.announce(:ticket_level_deleted, to_event("ticket_level.deleted", :event, :nonprofit, :event_discounts).attributes!)
  end

  def amount_hasnt_changed_if_has_tickets
    if tickets.any?
      console.log("YOU can't change amount if tickets already use this #{ticket_level.id}. Please create a new level")
    end
  end
end
