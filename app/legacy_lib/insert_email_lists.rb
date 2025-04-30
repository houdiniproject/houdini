# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"

module InsertEmailLists
  def self.for_mailchimp(npo_id, tag_master_ids)
    # Partial SQL expression for deleting deselected tags
    tags_for_nonprofit = Nonprofit.includes(tag_masters: :email_list).find(npo_id).tag_masters.not_deleted
    tag_master_ids = tags_for_nonprofit.where("id in (?)", tag_master_ids).pluck(:id)
    if tag_master_ids.empty? # no tags were selected; remove all email lists
      deleted = tags_for_nonprofit.includes(:email_list).where("email_lists.id IS NOT NULL").references(:email_lists).map { |i| i.email_list }
      EmailList.where("id IN (?)", deleted.map { |i| i.id }).delete_all
    else # Remove all email lists that exist in the db that are not included in tag_master_ids
      deleted = tags_for_nonprofit.includes(:email_list).where("email_lists.tag_master_id NOT IN (?)", tag_master_ids).references(:email_lists).map { |i| i.email_list }
      EmailList.where("id IN (?)", deleted.map { |i| i.id }).delete_all
    end
    mailchimp_lists_to_delete = deleted.map { |i| i.mailchimp_list_id }
    result = Mailchimp.delete_mailchimp_lists(npo_id, mailchimp_lists_to_delete)

    return {deleted: deleted.map { |i| {"mailchimp_list_id" => i.mailchimp_list_id} }, deleted_result: result} if tag_master_ids.empty?

    existing = tags_for_nonprofit.includes(:email_list).where("email_lists.tag_master_id IN (?)", tag_master_ids).references(:email_lists)

    tag_master_ids -= existing.map { |i| i.id }

    lists = Mailchimp.create_mailchimp_lists(npo_id, tag_master_ids)
    if !lists || !lists.any? || !lists.first[:name]
      raise Exception.new("Unable to create mailchimp lists. Response was: #{lists}")
    end

    inserted_lists = Qx.insert_into(:email_lists)
      .values(lists.map { |ls| {list_name: ls[:name], mailchimp_list_id: ls[:id], tag_master_id: ls[:tag_master_id]} })
      .common_values({nonprofit_id: npo_id})
      .ts
      .returning("*")
      .execute

    Nonprofit.find(npo_id).email_lists.each(&:populate_list_later)

    {deleted: deleted.map { |i| {"mailchimp_list_id" => i.mailchimp_list_id} }, deleted_result: result, inserted_lists: inserted_lists, inserted_result: lists}
  end
end
