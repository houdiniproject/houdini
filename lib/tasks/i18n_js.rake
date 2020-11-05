# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
desc 'For generating the i18n-js exports at runtime. Overrides the built in i18n-js task'

namespace :i18n do
	namespace :js do
		task export: :environment do 
			GenerateLocales.generate
		end

		desc 'Delete all of the generated Javascript locales files'
		task clear: :environment do
			locales_dir = Rails.root.join('app', 'javascript', 'i18n', 'locales')
			FileUtils.remove_dir(locales_dir) if Dir.exists? locales_dir
		end
	end
end