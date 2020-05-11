# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Controllers::Locale
    extend ActiveSupport::Concern

    included do 
        before_action :set_locale

        def set_locale
            if params[:locale] && Settings.available_locales.include?(params[:locale])
              I18n.locale = params[:locale]
            else
              I18n.locale = Settings.language
            end
        end
    end
end