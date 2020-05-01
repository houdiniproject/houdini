# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
 namespace :houdini_upgrade do
  Rake::Task["install:migrations"].clear_comments
  desc "Run houdini upgrade to v2"
  task :run  => :environment do
      Rake::Task["houdini_upgrade:install:migrations"].invoke
      Rake::Task["houdini_upgrade:run_db_migration"].invoke
  end

  task :run_db_migration do
    sh 'rails db:migrate'
  end
end
