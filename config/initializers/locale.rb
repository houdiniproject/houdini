# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
I18n.available_locales = Settings.available_locales
Rails.application.config.i18n.fallbacks = [I18n.default_locale]
