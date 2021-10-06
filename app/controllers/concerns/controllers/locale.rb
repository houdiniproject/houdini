# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# rubocop:disable Style/ConditionalAssignment
module Controllers::Locale
	extend ActiveSupport::Concern

	included do
		before_action :set_locale

		private

		def set_locale
			if params[:locale] && Houdini.intl.available_locales.include?(params[:locale])
				I18n.locale = params[:locale]
			else
				I18n.locale = Houdini.intl.language
			end
		end
	end
end
# rubocop:enable all
