# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'queue_donations'

namespace :civicrm do
  desc 'pushes donation records to CiviCRM'
  task push: :environment do
    QueueDonations.execute_all
  end

  desc "pushes donation records to CiviCRM, but doesn't mark them as pushed (useful for debugging)"
  task dry_run: :environment do
    QueueDonations.dry_execute_all
  end
end
