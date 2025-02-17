# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# engine initializer for everything international
module Houdini::EngineInitializers::Intl
  extend ActiveSupport::Concern
  included do
    initializer "houdini.intl.set_configs",
      before: "houdini.finish_configs" do |app|
      app.config.to_prepare do
        Houdini.intl = Houdini::Intl.new(app.config.houdini.intl.to_h)
        Houdini.intl.all_countries ||= ISO3166::Country.all.map(&:alpha2)
        Houdini.intl.all_currencies ||= Money::Currency.table
        if Houdini.intl.available_locales.map(&:to_s)
            .none? { |l| l == Houdini.intl.language.to_s }
          raise("The language #{Houdini.intl.language} is not listed \
		in the provided locales: #{Houdini.intl.available_locales.join(", ")}")
        end
      end
    end

    config.houdini.intl = ActiveSupport::OrderedOptions.new
    config.houdini.intl.language = :en
    config.houdini.intl.available_locales = %i[en de es fr it nl pl ro]
    config.houdini.intl.all_countries = nil
    config.houdini.intl.currencies = ["usd"]
    config.houdini.intl.all_currencies = nil
  end
end
