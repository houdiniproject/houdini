# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::FullContact::FullContactJob < Houdini::FullContact::ApplicationJob
  queue_as :full_contact_queue

  retry_on Exception, wait: ->(executions) { executions**2.195 }, attempts: Houdini::FullContact.max_attempts || 1

  def perform(supporter)
    Houdini::FullContact::InsertInfos.single(supporter)
  end
end
