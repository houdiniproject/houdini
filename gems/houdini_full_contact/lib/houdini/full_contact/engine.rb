# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::FullContact
  class Engine < ::Rails::Engine
    isolate_namespace Houdini::FullContact
    config.generators.api_only = true

    config.houdini.full_contact = ActiveSupport::OrderedOptions.new
    config.houdini.full_contact.max_attempts = 5

    initializer "houdini.full_contact.supporter_extension" do
      ActiveSupport.on_load(:houdini_supporter) do
        has_many :full_contact_infos, class_name: "Houdini::FullContact::Info"
      end
    end

    initializer "houdini.full_contact.configs" do
      config.before_initialize do |app|
        Houdini::FullContact.api_key = app.config.houdini.full_contact.api_key ||
          ENV.fetch("FULL_CONTACT_KEY")
        Houdini::FullContact.max_attempts = app.config.houdini.full_contact.max_attempts
      end
    end
  end
end
