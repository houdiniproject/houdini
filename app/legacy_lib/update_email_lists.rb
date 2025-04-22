# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateEmailLists
  def self.populate_lists_on_mailchimp(npo_id)
    Qx.select("tag_definition_id", "list_name", "mailchimp_list_id")
      .from(:email_lists)
      .where(nonprofit_id: npo_id)
      .execute
    post_data = Qx.select("supporters.email", "email_lists.mailchimp_list_id")
      .from("email_lists")
      .add_join("tag_definitions", "tag_definitions.id=email_lists.tag_definition_id")
      .add_join("tag_joins", "tag_joins.tag_definition_id=tag_definitions.id")
      .add_join("supporters", "supporters.id=tag_joins.supporter_id")
      .where("email_lists.nonprofit_id=$id", id: npo_id)
      .execute
      .map { |h| {method: "POST", path: "lists/#{h["mailchimp_list_id"]}/members", body: {email_address: h["email"], status: "subscribed"}.to_json} }
    Mailchimp.perform_batch_operations(npo_id, post_data)
  end
end
