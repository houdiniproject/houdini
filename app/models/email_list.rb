# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class EmailList < ApplicationRecord
  belongs_to :nonprofit
  belongs_to :tag_master

  has_many :tag_joins, through: :tag_master

  has_many :supporters, through: :tag_joins

  # you can set this manually for testing but generally, it should be
  # generated from the api key
  attr_accessor :base_uri

  # the path on the Mailchimp api for the list
  def list_path
    "lists/#{mailchimp_list_id}"
  end

  def list_url
    base_uri + "/" + list_path
  end

  # the path on the Mailchimp api for the list's members
  def list_members_path
    list_path + "/members"
  end

  def list_members_url
    base_uri + "/" + list_members_path
  end

  # the Mailchimp api key we have saved for the nonprofit
  def api_key
    Mailchimp.get_mailchimp_token(nonprofit.id)
  end

  # The base Mailchimp API uri. This includes getting the proper datacenter
  # using the api key.
  #
  # NOTE: this value is cached. This is not an awful decision but could be
  # easy to forget this
  def base_uri
    @base_uri ||= Mailchimp.base_uri(api_key)
  end

  def active?
    !deleted?
  end

  # true if we no longer want to sync that list, false if we do
  def deleted?
    tag_master&.deleted
  end

  # schedules a job to populate the list in the background
  def populate_list_later
    PopulateListJob.perform_later(self)
  end

  # populate the list by adding every Supporter in the list to mailchimp
  def populate_list
    unless deleted?
      Mailchimp.perform_batch_operations(nonprofit.id, supporters.all.map do |s|
        build_supporter_post_operation(s)
      end)
    end
  end

  def build_supporter_post_operation(supporter)
    MailchimpBatchOperation.new(method: "POST", list: self, supporter: supporter)
  end

  # we don't currently use this but we could in the future
  def build_supporter_delete_operation(supporter)
    MailchimpBatchOperation.new(method: "DELETE", list: self, supporter: supporter)
  end
end
