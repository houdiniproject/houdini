# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# an engine initializer for information about the hoster
module Houdini::EngineInitializers::Hoster
  extend ActiveSupport::Concern
  included do
    initializer "houdini.hoster.set_configs",
      before: "houdini.finish_configs" do |app|
      app.config.to_prepare do
        options = app.config.houdini.hoster

        options.support_email ||= ActionMailer::Base.default[:from]
        options.main_admin_email ||= ActionMailer::Base.default[:from]

        options.each { |k, v| Houdini::Hoster.send("#{k}=", v) }
      end
    end

    config.houdini.hoster = ActiveSupport::OrderedOptions.new
    config.houdini.hoster.terms_and_privacy = ActiveSupport::OrderedOptions.new
  end
end
