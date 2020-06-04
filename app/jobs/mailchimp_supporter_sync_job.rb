class MailchimpSupporterSyncJob < ApplicationJob
  queue_as :default

  def perform(np_id, supporter_ids, tag_data)
    Mailchimp.sync_supporters_to_list_from_tag_joins(np_id, supporter_ids, tag_data)
  end
end
