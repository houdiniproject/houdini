# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class EventDiscount < ApplicationRecord
  include Model::Eventable
  # :code,
  # :event_id,
  # :name,
  # :percent
  validates :name, presence: true
  validates :code, presence: true
  validates :event, presence: true
  validates :percent, presence: true, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: 100}

  
  # we use after_create_commit because the db could be in an inconsistent state and the messages will be slightly wrong
  # we use after commit on the rest for consistency
  after_create_commit :publish_create
  after_destroy_commit :publish_delete
  after_update_commit :publish_updated

  belongs_to :event
  has_many :tickets

  def to_builder(*expand)
    Jbuilder.new do |json|
      json.(self, :id, :name, :code)
      json.deleted !persisted?
      json.object 'event_discount'
      json.discount do 
        json.percent percent
      end

      if event
        if expand.include? :event
          json.event event.to_builder
        else
          json.event event.id
        end
        if event.nonprofit
          if expand.include? :nonprofit
            json.nonprofit event.nonprofit.to_builder
          else
            json.nonprofit event.nonprofit.id
          end
        else 
          json.nonprofit nil
        end

        if expand.include? :ticket_levels
          json.ticket_levels event.ticket_levels do |tl|
            json.merge! tl.to_builder.attributes!
          end
        else
          json.ticket_levels event.ticket_levels.pluck(:id)
        end
      end
    end
  end

  private
  def publish_create
    Houdini.event_publisher.announce(:event_discount_created, to_event('event_discount.created', :event, :nonprofit, :ticket_levels).attributes!)
  end

  def publish_updated
    Houdini.event_publisher.announce(:event_discount_updated, to_event('event_discount.updated', :event, :nonprofit, :ticket_levels).attributes!)
  end

  def publish_delete
    Houdini.event_publisher.announce(:event_discount_deleted, to_event('event_discount.deleted', :event, :nonprofit, :ticket_levels).attributes!)
  end
end
