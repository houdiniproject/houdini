# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class WebhookTransmitJob < ApplicationJob
  queue_as :default

  def perform(object_event_hook_config, payload)
    object_event_hook_config.webhook.transmit(payload)
  end
end
