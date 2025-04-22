# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class DripEmailList < ApplicationRecord
  validates :mailchimp_list_id, presence: true

  # the path on the Mailchimp api for the list
  def list_path
    "lists/#{mailchimp_list_id}"
  end

  # the path on the Mailchimp api for the list's members
  def list_members_path
    list_path + "/members"
  end
end
