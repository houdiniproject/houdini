# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

namespace :settings do
  task :environment do
    require File.expand_path("../../config/environment.rb", File.dirname(__FILE__))
  end

  desc "show settings"
  task show: :environment do
    require "pp"
    pp Settings.to_hash
  end

  task generate_json: :environment do
    cdn_url = URI(Settings.cdn.url)
    cdn_url = cdn_url.to_s
    if Settings.button_config&.url
      cdn_url = URI(Settings.button_config.url).to_s
    end
    c = {button: {url: cdn_url, css: "#{cdn_url}/css/donate-button.v2.css"}}
    open(File.expand_path("config/settings.json", Rails.root), "w") do |f|
      f.write(c.to_json)
    end
  end

  task combine_translations: "i18n:js:export" do
    js_root = File.expand_path("public/javascripts", Rails.root)
    # i18n = File.read(File.join(js_root, 'i18n.js'))
    translations = File.read(File.join(js_root, "translations.js"))
    open(File.join(js_root, "_final.js"), "w") do |f|
      f.write("const I18n = require('i18n-js');\n" + translations + "\n window.I18n = I18n")
    end
  end
end
