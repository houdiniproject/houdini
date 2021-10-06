# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'qx'

module InsertEmailLists
  def self.for_mailchimp(npo_id, tag_master_ids)
    # Partial SQL expression for deleting deselected tags
    delete_expr = Qx.delete_from(:email_lists).where(nonprofit_id: npo_id).returning('mailchimp_list_id')

    if tag_master_ids.empty? # no tags were selected; remove all email lists
      deleted = delete_expr.execute
    else # Remove all email lists that exist in the db that are not included in tag_master_ids
      deleted = delete_expr.where('tag_master_id NOT IN($ids)', ids: tag_master_ids).execute
    end
    mailchimp_lists_to_delete = deleted.map { |h| h['mailchimp_list_id'] }
    result = Mailchimp.delete_mailchimp_lists(npo_id, mailchimp_lists_to_delete)

    return { deleted: deleted, deleted_result: result } if tag_master_ids.empty?

    existing = Qx.select('tag_master_id').from(:email_lists)
                 .where(nonprofit_id: npo_id)
                 .and_where('tag_master_id IN ($ids)', ids: tag_master_ids)
                 .execute
    tag_master_ids -= existing

    lists = Mailchimp.create_mailchimp_lists(npo_id, tag_master_ids)
    if !lists || lists.none? || !lists.first[:name]
      raise Exception, "Unable to create mailchimp lists. Response was: #{lists}"
    end

    inserted_lists = Qx.insert_into(:email_lists)
                       .values(lists.map { |ls| { list_name: ls[:name], mailchimp_list_id: ls[:id], tag_master_id: ls[:tag_master_id] } })
                       .common_values(nonprofit_id: npo_id)
                       .ts
                       .returning('*')
                       .execute

    EmailListCreateJob.perform_later(npo_id)

    { deleted: deleted, deleted_result: result, inserted_lists: inserted_lists, inserted_result: lists }
  end
end
