class EmailListCreateJob < ApplicationJob
  queue_as :default

  def perform(npo_id)
    UpdateEmailLists.populate_lists_on_mailchimp(npo_id)
  end
end
