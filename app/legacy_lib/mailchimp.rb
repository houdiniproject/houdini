# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "httparty"
require "digest/md5"

module Mailchimp
  include HTTParty
  format :json

  def self.base_uri(key)
    dc = get_datacenter(key)
    "https://#{dc}.api.mailchimp.com/3.0"
  end

  # Run the configuration from an initializer
  # data: {:api_key => String}
  def self.config(hash)
    @options = {
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json"
      }
    }
    @body = {
      apikey: hash[:api_key]
    }
  end

  # Given a nonprofit mailchimp oauth2 key, return its current datacenter
  def self.get_datacenter(key)
    metadata = HTTParty.get("https://login.mailchimp.com/oauth2/metadata",
      headers: {
        "User-Agent" => "oauth2-draft-v10",
        "Host" => "login.mailchimp.com",
        "Accept" => "application/json",
        "Authorization" => "OAuth #{key}"
      })
    metadata["dc"]
  end

  def self.signup(email, mailchimp_list_id)
    body_hash = @body.merge(
      id: mailchimp_list_id,
      email: {email: email}
    )
    post("/lists/subscribe", @options.merge(body: body_hash.to_json)).parsed_response
  end

  def self.get_mailchimp_token(npo_id)
    mailchimp_token = QueryNonprofitKeys.get_key(npo_id, "mailchimp_token")
    throw RuntimeError.new("No Mailchimp connection for this nonprofit: #{npo_id}") if mailchimp_token.nil?
    mailchimp_token
  end

  # Given a nonprofit id and a list of tag definition ids that they make into email lists,
  # create those email lists on mailchimp and return an array of hashes of mailchimp list ids, names, and tag_definition_id
  def self.create_mailchimp_lists(npo_id, tag_definition_ids)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    puts "URI #{uri}"
    puts "KEY #{mailchimp_token}"

    npo = Qx.fetch(:nonprofits, npo_id).first
    tags = Qx.select("DISTINCT(tag_definitions.name) AS tag_name, tag_definitions.id")
      .from(:tag_definitions)
      .where("tag_definitions.nonprofit_id" => npo_id)
      .and_where("tag_definitions.id IN ($ids)", ids: tag_definition_ids)
      .join(:nonprofits, "tag_definitions.nonprofit_id = nonprofits.id")
      .execute

    tags.map do |h|
      list = post(uri + "/lists",
        basic_auth: {username: "", password: mailchimp_token},
        headers: {"Content-Type" => "application/json"},
        body: {
          name: "CommitChange-" + h["tag_name"],
          contact: {
            company: npo["name"],
            address1: npo["address"] || "",
            city: npo["city"] || "",
            state: npo["state_code"] || "",
            zip: npo["zip_code"] || "",
            country: npo["state_code"] || "",
            phone: npo["phone"] || ""
          },
          permission_reminder: "You are a registered supporter of our nonprofit.",
          campaign_defaults: {
            from_name: npo["name"] || "",
            from_email: npo["email"].presence || "support@commichange.com",
            subject: "Enter your subject here...",
            language: "en"
          },
          email_type_option: false,
          visibility: "prv"
        }.to_json)
      raise Exception, "Failed to create list: #{list}" if list.code != 200

      {id: list["id"], name: list["name"], tag_definition_id: h["id"]}
    end
  end

  # Given a nonprofit id and post_data, which is an array of batch operation hashes
  # See here: http://developer.mailchimp.com/documentation/mailchimp/guides/how-to-use-batch-operations/
  # Perform all the batch operations and return a status report
  def self.perform_batch_operations(npo_id, post_data)
    return if post_data.empty?

    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    batch_job_id = post(uri + "/batches",
      basic_auth: {username: "CommitChange", password: mailchimp_token},
      headers: {"Content-Type" => "application/json"},
      body: {operations: post_data}.to_json)["id"]
    check_batch_status(npo_id, batch_job_id)
  end

  def self.check_batch_status(npo_id, batch_job_id)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    get(uri + "/batches/" + batch_job_id,
      basic_auth: {username: "CommitChange", password: mailchimp_token},
      headers: {"Content-Type" => "application/json"})
  end

  def self.delete_mailchimp_lists(npo_id, mailchimp_list_ids)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    mailchimp_list_ids.map do |id|
      delete(uri + "/lists/#{id}", basic_auth: {username: "CommitChange", password: mailchimp_token})
    end
  end

  # `removed` and `added` are arrays of tag join ids that have been added or removed to a supporter
  def self.sync_supporters_to_list_from_tag_joins(npo_id, supporter_ids, tag_data)
    emails = Qx.select(:email).from(:supporters).where("id IN ($ids)", ids: supporter_ids).execute.map { |h| h["email"] }
    to_add = get_mailchimp_list_ids(tag_data.select { |h| h["selected"] }.map { |h| h["tag_definition_id"] })
    to_remove = get_mailchimp_list_ids(tag_data.reject { |h| h["selected"] }.map { |h| h["tag_definition_id"] })
    return if to_add.empty? && to_remove.empty?

    bulk_post = emails.map { |em| to_add.map { |ml_id| {method: "POST", path: "lists/#{ml_id}/members", body: {email_address: em, status: "subscribed"}.to_json} } }.flatten
    bulk_delete = emails.map { |em| to_remove.map { |ml_id| {method: "DELETE", path: "lists/#{ml_id}/members/#{Digest::MD5.hexdigest(em.downcase)}"} } }.flatten
    perform_batch_operations(npo_id, bulk_post.concat(bulk_delete))
  end

  def self.get_mailchimp_list_ids(tag_definition_ids)
    return [] if tag_definition_ids.empty?

    Qx.select("email_lists.mailchimp_list_id")
      .from(:tag_definitions)
      .where("tag_definitions.id IN ($ids)", ids: tag_definition_ids)
      .join("email_lists", "email_lists.tag_definition_id=tag_definitions.id")
      .execute.map { |h| h["mailchimp_list_id"] }
  end

  # @param [Nonprofit] nonprofit
  def self.hard_sync_lists(nonprofit)
    return unless nonprofit

    nonprofit.tag_definitions.not_deleted.each do |i|
      hard_sync_list(i.email_list) if i.email_list
    end
  end

  # @param [EmailList] email_list
  # Notably, if a supporter unsubscribed on Mailchimp, this will not
  # resubscribe them. This is the correct behavior.
  def self.hard_sync_list(email_list)
    ops = generate_batch_ops_for_hard_sync(email_list)
    perform_batch_operations(email_list.nonprofit.id, ops)
  end

  def self.generate_batch_ops_for_hard_sync(email_list)
    # get the subscribers from mailchimp
    mailchimp_subscribers = get_list_mailchimp_subscribers(email_list)
    # get our subscribers
    our_supporters = email_list.tag_definition.tag_joins.map(&:supporter)

    # split them as follows:
    # on both lists, on our list, on the mailchimp list
    _, in_mailchimp_only = mailchimp_subscribers.partition do |mc_sub|
      our_supporters.any? { |s| s.email.casecmp(mc_sub[:email_address]).zero? }
    end

    _, in_our_side_only = our_supporters.partition do |s|
      mailchimp_subscribers.any? { |mc_sub| s.email.casecmp(mc_sub[:email_address]).zero? }
    end

    # if on our list, add to mailchimp
    output = in_our_side_only.map do |i|
      {method: "POST", path: "lists/#{email_list.mailchimp_list_id}/members", body: {email_address: i.email, status: "subscribed"}.to_json}
    end

    # if on mailchimp list, delete from mailchimp
    output.concat(in_mailchimp_only.map { |i| {method: "DELETE", path: "lists/#{email_list.mailchimp_list_id}/members/#{i[:id]}"} })
  end

  def self.get_list_mailchimp_subscribers(email_list)
    mailchimp_token = get_mailchimp_token(email_list.tag_definition.nonprofit.id)
    uri = base_uri(mailchimp_token)
    result = get(uri + "/lists/#{email_list.mailchimp_list_id}/members?count=1000000000",
      basic_auth: {username: "CommitChange", password: mailchimp_token},
      headers: {"Content-Type" => "application/json"})
    result["members"].map do |i|
      {id: i["id"], email_address: i["email_address"]}
    end.to_a
  end

  def self.get_email_lists(nonprofit)
    mailchimp_token = get_mailchimp_token(nonprofit.id)
    uri = base_uri(mailchimp_token)
    result = get(uri + "/lists",
      basic_auth: {username: "CommitChange", password: mailchimp_token},
      headers: {"Content-Type" => "application/json"})
    result["lists"]
  end
end
