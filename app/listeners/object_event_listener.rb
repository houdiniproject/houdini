# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class ObjectEventListener < ApplicationListener
  def self.campaign_gift_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_option_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_option_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_option_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_purchase_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_purchase_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.campaign_gift_purchase_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.event_discount_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.event_discount_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.event_discount_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_level_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_level_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_level_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_purchase_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_purchase_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.ticket_purchase_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_address_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_address_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_address_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_note_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_note_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.supporter_note_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.donation_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.donation_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.donation_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.custom_field_definition_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.custom_field_definition_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.tag_definition_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.tag_definition_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_refund_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_refund_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_refund_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_dispute_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_dispute_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.offline_transaction_dispute_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.stripe_transaction_dispute_created(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.stripe_transaction_dispute_updated(event)
    enqueue_transmissions_to_webhooks(event)
  end

  def self.stripe_transaction_dispute_deleted(event)
    enqueue_transmissions_to_webhooks(event)
  end

  private

  def self.enqueue_transmissions_to_webhooks(event)
    object_event_hook_configs(event).each do |config|
      WebhookTransmitJob.perform_later(config, event)
    end
  end

  def self.object_event_hook_configs(event)
    nonprofit(event).object_event_hook_configs.for_type(event["type"])
  end

  def self.nonprofit(event)
    nonprofit_id = event["data"]["object"]["nonprofit"]["id"]
    Nonprofit.find_by_id(nonprofit_id)
  end
end
