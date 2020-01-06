# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
HoudiniEventPublisher = EventPublisher.new

Rails.application.config.to_prepare do
    HoudiniEventPublisher.clear if Rails.env.development?

    HoudiniEventPublisher.subscribe_async(NonprofitMailerListener.new)
end
