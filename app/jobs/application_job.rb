# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# newer versions of Rails use an ApplicationJob so let's be cool like them
class ApplicationJob < ActiveJob::Base
  queue_as :default
end
