# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PopulateListJob < ApplicationJob
  queue_as :default

  def perform(email_list)
    email_list.populate_list
  end
end
