# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

namespace :settings do
  task :environment do
    require File.expand_path('../../config/environment.rb', File.dirname(__FILE__))
  end
end
