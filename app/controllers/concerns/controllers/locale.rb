# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# rubocop:disable Style/ConditionalAssignment
module Controllers::Locale
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale

    private

    def switch_locale(&action)
      locale = if available_locales.include?(params[:locale])
        params[:locale]
      else
        extract_locale_from_accept_language_header
      end

      logger.debug "* Locale set to '#{locale}'"
      I18n.with_locale(locale, &action)
    end

    def extract_locale_from_accept_language_header
      # override compared to Houdini because we don't have bess yet
      Settings.language
    end

    def available_locales
      # we don't have bess so override
      Settings.available_locales.map { |locale| locale.to_s }
    end
  end
end
# rubocop:enable all
