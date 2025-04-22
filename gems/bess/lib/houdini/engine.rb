# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "active_support"
require "active_support/rails"
require "active_support/core_ext/numeric/time" # we need this becuase 20.minutes isn't loaded otherwise?

module Houdini
  class Engine < ::Rails::Engine
    config.generators do |g|
      g.test_framework :rspec
    end

    config.houdini = ActiveSupport::OrderedOptions.new

    config.houdini.core_classes = {supporter: "Supporter", nonprofit: "Nonprofit"}

    config.houdini.general = ActiveSupport::OrderedOptions.new
    config.houdini.general.name = "Houdini Project"
    config.houdini.general.logo = "logos/houdini_project_bug.svg"
    config.houdini.general.logo_full = "logos/houdini_project_full.svg"
    config.houdini.general.poweredby_logo = "logos/houdini_project_rectangle_150.png"

    config.houdini.defaults = ActiveSupport::OrderedOptions.new
    config.houdini.defaults.image = ActiveSupport::OrderedOptions.new
    config.houdini.defaults.image.profile = "public/images/fallback/default-profile.png"
    config.houdini.defaults.image.nonprofit = "public/images/fallback/default-nonprofit.png"
    config.houdini.defaults.image.campaign = "public/fallback/default-campaign-background.jpg"
    config.houdini.defaults.image.event = "public/fallback/default-campaign-background.jpg"

    config.houdini.payment_providers = ActiveSupport::OrderedOptions.new

    config.houdini.payment_providers.stripe = ActiveSupport::OrderedOptions.new
    config.houdini.payment_providers.stripe.public_key = ENV["STRIPE_API_PUBLIC"]
    config.houdini.payment_providers.stripe.private_key = ENV["STRIPE_API_KEY"]
    config.houdini.payment_providers.stripe.connect = false
    config.houdini.payment_providers.stripe.proprietary_v2_js = false

    config.houdini.maps = ActiveSupport::OrderedOptions.new

    config.houdini.default_bp = ActiveSupport::OrderedOptions.new
    config.houdini.default_bp.id = 1

    config.houdini.page_editor = ActiveSupport::OrderedOptions.new
    config.houdini.page_editor.editor = "quill"

    config.houdini.source_tokens = ActiveSupport::OrderedOptions.new
    config.houdini.source_tokens.max_uses = 1
    config.houdini.source_tokens.expiration_time = 20.minutes
    config.houdini.source_tokens.event_donation_source = ActiveSupport::OrderedOptions.new
    config.houdini.source_tokens.event_donation_source.max_uses = 20
    config.houdini.source_tokens.event_donation_source.expiration_after_event = 20.days

    config.houdini.show_state_field = true

    config.houdini.nonprofits_must_be_vetted = false

    config.houdini.terms_and_privacy = ActiveSupport::OrderedOptions.new

    config.houdini.ccs = :local_tar_gz
    config.houdini.ccs_options = nil

    config.houdini.maintenance = ActiveSupport::OrderedOptions.new
    config.houdini.maintenance.active = false

    config.houdini.listeners = []

    initializer "houdini.set_configuration", before: "houdini.finish_configuration" do |app|
      app.config.to_prepare do
        Houdini.core_classes = app.config.houdini.core_classes

        Houdini.button_host = app.config.houdini.button_host ||
          ActionMailer::Base.default_url_options[:host]

        Houdini.payment_providers = Houdini::PaymentProvider::Registry.new(app.config.houdini.payment_providers).build_all

        Houdini.general = app.config.houdini.general
        Houdini.defaults = app.config.houdini.defaults

        ccs = app.config.houdini.ccs
        options = app.config.houdini.ccs_options || {}
        Houdini.ccs = Houdini::Ccs.build(ccs,
            **options)

        Houdini.maintenance = Houdini::Maintenance.new(app.config.houdini.maintenance.to_h)

        Houdini.source_tokens = app.config.houdini.source_tokens

        Houdini.page_editor = app.config.houdini.page_editor

        Houdini.maps = app.config.houdini.maps

        Houdini.nonprofits_must_be_vetted = app.config.houdini.nonprofits_must_be_vetted
        Houdini.show_state_field = app.config.houdini.show_state_field
        Houdini.default_bp = app.config.houdini.default_bp.id

        Houdini.event_publisher.subscribe_all(app.config.houdini.listeners)
      end
    end

    initializer "houdini.finish_configuration", before: "factory_bot.set_fixture_replacement" do |app|
      # nothing to do, we just want to make sure we have proper initializer order
    end

    include Houdini::EngineInitializers
  end
end
