# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module Houdini
  extend ActiveSupport::Autoload

  autoload :Ccs
  autoload :Maintenance
  autoload :Intl
  autoload :PaymentProvider
  autoload :EventPublisher
  autoload :WebhookAdapter
  autoload :NonprofitCreation
  autoload :Hoster
  autoload :EngineInitializers

  mattr_accessor :intl, :maintenance, :ccs

  mattr_accessor :general, default: {}
  mattr_accessor :defaults, default: {}

  mattr_accessor :payment_providers, default: {}

  mattr_accessor :maps, default: {}
  mattr_accessor :default_bp, default: {}

  mattr_accessor :page_editor, default: {}

  mattr_accessor :source_tokens, default: {}

  mattr_accessor :show_state_field, default: true

  mattr_accessor :nonprofits_must_be_vetted, default: false
  mattr_accessor :button_host

  mattr_accessor :hoster, default: Houdini::Hoster

  mattr_accessor :core_classes, default: {supporter: "Supporter", nonprofit: "Nonprofit"}

  mattr_accessor :event_publisher, default: Houdini::EventPublisher.new
end

# need to have Houdini loaded first before we can add engine
require "houdini/engine"
