# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
desc "Javascript related tasks"
namespace :js do
  desc "generate all the pre-build Javascript"
  task generate: ["js:routes:typescript", "i18n:js:export"]
  namespace :routes do
    desc "delete generated route files"
    task clean: :environment do
      js_dir = Rails.root.join("app/javascript")
      FileUtils.rm_f js_dir.join("routes.js")
      FileUtils.rm_f js_dir.join("routes.d.ts")
    end
  end
end
