# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ObjectEventHookConfig < ApplicationRecord
  # :webhook_service, #str, webhook service to be called
  # :configuration, #jsonb, configuration needed to connect to the webhook
  # :object_event_types, #jsonb, must be an array

  belongs_to :nonprofit

  validates :webhook_service, presence: true
  validates :configuration, presence: true
  validates :object_event_types, presence: true, length: {minimum: 1}

  def webhook
    Houdini::WebhookAdapter.build(webhook_service, configuration.symbolize_keys)
  end
end
