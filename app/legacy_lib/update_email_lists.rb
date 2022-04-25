# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module UpdateEmailLists

  def self.populate_lists_on_mailchimp(npo_id)
    post_data = Qx.select("supporters.email", "email_lists.mailchimp_list_id")
      .from("email_lists")
      .add_join("tag_masters", "tag_masters.id=email_lists.tag_master_id")
      .add_join("tag_joins", "tag_joins.tag_master_id=tag_masters.id")
      .add_join("supporters", "supporters.id=tag_joins.supporter_id")
      .where("email_lists.nonprofit_id=$id", id: npo_id)
      .execute
      .map{|h| {method: 'POST', path: "lists/#{h['mailchimp_list_id']}/members", body: {email_address: h['email'], status: 'subscribed'}.to_json}}
    Mailchimp.perform_batch_operations(npo_id, post_data)
  end

end
