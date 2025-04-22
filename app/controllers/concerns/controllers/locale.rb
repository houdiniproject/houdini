# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Locale
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale

    private

    # We decide on the locale based on the request headers, extracted by 'http_accept_language' gem,
    # unless the request comes with a locale param, then we override it.
    def switch_locale(&action)
      locale = if available_locales.include?(params[:locale])
        params[:locale].tr("-", "_")
      else
        extract_locale_from_accept_language_header
      end
      logger.debug "* Locale set to '#{locale}'"
      I18n.with_locale(locale, &action)
    end

    def extract_locale_from_accept_language_header
      require "http_accept_language" unless defined? HttpAcceptLanguage
      parser = HttpAcceptLanguage::Parser.new(request.env["HTTP_ACCEPT_LANGUAGE"])
      matched = parser.language_region_compatible_from(available_locales)&.tr("-", "_")
      matched || Houdini.intl.language
    end

    def available_locales
      Houdini.intl.available_locales.map { |locale| locale.to_s.tr("_", "-") }
    end
  end
end
