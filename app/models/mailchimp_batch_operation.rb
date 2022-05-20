# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# represents an operation using Mailchimp's batch subscribe/unsubscribe
# See more at: https://mailchimp.com/developer/marketing/api/list-members/
class MailchimpBatchOperation
  include ActiveModel::Model
  
  attr_accessor :method, # POST or DELETE
    :list, # the EmailList you're applying this to
    :supporter # the Supporter in question

  def body
    method === "POST" ? Mailchimp::create_subscribe_body(supporter) : nil
  end

  def path
    path = list.list_members_path
    path = path + "/#{Digest::MD5.hexdigest(supporter.email.downcase).to_s}" if method === "DELETE" 
    path
  end

  def to_h
    if (supporter.email) 
      result = {method: method, path: path}
      if body
        result[:body] = body
      end
      result
    else
      nil
    end
  end
end
