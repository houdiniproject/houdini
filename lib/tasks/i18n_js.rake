# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE


def enhance_assets_precompile
  # yarn:install was added in Rails 5.1
  Rake::Task["assets:precompile"].enhance(['i18n:js:export'])
end

def enhance_webpacker_compile
  # yarn:install was added in Rails 5.1
  Rake::Task["webpacker:compile"].enhance(['i18n:js:export'])
end

def enhance_assets_clean_and_clobber
	Rake::Task["assets:clean"].enhance(['i18n:js:clean'])
	Rake::Task["assets:clobber"].enhance(['i18n:js:clean'])
end

desc 'For generating the i18n-js exports at runtime. Overrides the built in i18n-js task'
namespace :i18n do
	namespace :js do
		task export: :environment do 
			GenerateLocales.generate
		end

		desc 'Delete all of the generated Javascript locales files'
		task clean: :environment do
			locales_dir = Rails.root.join('app', 'javascript', 'i18n', 'locales')
			FileUtils.remove_dir(locales_dir) if Dir.exists? locales_dir
		end
	end
end

enhance_assets_precompile
enhance_webpacker_compile
enhance_assets_clean_and_clobber