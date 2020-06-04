# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

namespace :settings do
  task :environment do
    require File.expand_path('../../config/environment.rb', File.dirname(__FILE__))
  end

  desc 'show settings'
  task show: :environment do
    require 'pp'
    pp Settings.to_hash
  end
end
