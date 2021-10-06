# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class ImportCreationJob < ApplicationJob
  queue_as :default

  def perform(import_request, current_user)
    import_request.execute_safe(current_user)
  end
end
