# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "httparty"
require "digest/md5"

module Mailchimp
  include HTTParty
  format :json
  logger Rails.logger, :info, :mailchimp

  def self.base_uri(key)
    dc = get_datacenter(key)
    "https://#{dc}.api.mailchimp.com/3.0"
  end

  # Run the configuration from an initializer
  # data: {:api_key => String}
  def self.config(hash)
    @apikey = hash[:api_key]
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
    metadata = HTTParty.get("https://login.mailchimp.com/oauth2/metadata", {
      headers: {
        "User-Agent" => "oauth2-draft-v10",
        "Host" => "login.mailchimp.com",
        "Accept" => "application/json",
        "Authorization" => "OAuth #{key}",
        "apikey" => @apikey
      },
      logger: Rails.logger,
      log_level: :info,
      log_format: :mailchimp
    })
    metadata["dc"]
  end

  def self.signup supporter, mailchimp_list
    body_hash = @body.merge(create_subscribe_body(supporter))
    put(mailchimp_list.list_members_url, @options.merge(body: body_hash.to_json))
  end

  def self.signup_nonprofit_user(drip_email_list, nonprofit, user)
    body_hash = @body.merge(create_nonprofit_user_subscribe_body(nonprofit, user))
    uri = "https://us5.api.mailchimp.com/3.0" # hardcoded for us
    put(uri + "/" + generate_list_member_path(drip_email_list.list_members_path, user.email), @options.merge(body: body_hash.to_json,
      basic_auth: {username: "user", password: @apikey}))
  end

  def self.get_mailchimp_token(npo_id)
    mailchimp_token = QueryNonprofitKeys.get_key(npo_id, "mailchimp_token")
    throw RuntimeError.new("No Mailchimp connection for this nonprofit: #{npo_id}") if mailchimp_token.nil?
    mailchimp_token
  end

  # Get all lists owned by the nonprofit represented by the mailchimp token
  def get_all_lists(mailchimp_token)
    uri = base_uri(mailchimp_token)
    puts "URI #{uri}"
    puts "KEY #{mailchimp_token}"
    get(uri + "/lists", {
      basic_auth: {username: "", password: mailchimp_token},
      headers: {"Content-Type" => "application/json"}
    })
  end

  # Given a nonprofit id and a list of tag master ids that they make into email lists,
  # create those email lists on mailchimp and return an array of hashes of mailchimp list ids, names, and tag_master_id
  def self.create_mailchimp_lists(npo_id, tag_master_ids)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    puts "URI #{uri}"
    puts "KEY #{mailchimp_token}"

    npo = Qx.fetch(:nonprofits, npo_id).first
    tags = Qx.select("DISTINCT(tag_masters.name) AS tag_name, tag_masters.id")
      .from(:tag_masters)
      .where({"tag_masters.nonprofit_id" => npo_id})
      .and_where("tag_masters.id IN ($ids)", ids: tag_master_ids)
      .join(:nonprofits, "tag_masters.nonprofit_id = nonprofits.id")
      .execute

    tags.map do |h|
      list = post(uri + "/lists", {
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
            country: "US",
            phone: npo["phone"] || ""
          },
          permission_reminder: "You are a registered supporter of our nonprofit.",
          campaign_defaults: {
            from_name: npo["name"] || "",
            from_email: npo["email"].presence || "support@commitchange.com",
            subject: "Enter your subject here...",
            language: "en"
          },
          email_type_option: false,
          visibility: "prv"
        }.to_json
      })
      if list.code != 200
        raise Exception.new("Failed to create list: #{list}")
      end
      {id: list["id"], name: list["name"], tag_master_id: h["id"]}
    end
  end

  # Given a nonprofit id and post_data, which is an array of batch operation hashes OR MailchimpBatchOperation objects
  # See here: http://developer.mailchimp.com/documentation/mailchimp/guides/how-to-use-batch-operations/
  # Perform all the batch operations and return a status report
  def self.perform_batch_operations(npo_id, post_data)
    post_data = post_data.map(&:to_h).select(&:present?) # the select removes any nil items
    return if post_data.empty?
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    batch_job_id = post(uri + "/batches", {
      basic_auth: {username: @username, password: mailchimp_token},
      headers: {"Content-Type" => "application/json"},
      body: {operations: post_data}.to_json
    })["id"]
    check_batch_status(npo_id, batch_job_id)
  end

  def self.check_batch_status(npo_id, batch_job_id)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    get(uri + "/batches/" + batch_job_id, {
      basic_auth: {username: @username, password: mailchimp_token},
      headers: {"Content-Type" => "application/json"}
    })
  end

  def self.delete_mailchimp_lists(npo_id, mailchimp_list_ids)
    mailchimp_token = get_mailchimp_token(npo_id)
    uri = base_uri(mailchimp_token)
    mailchimp_list_ids.map do |id|
      delete(uri + "/lists/#{id}", {basic_auth: {username: "CommitChange", password: mailchimp_token}})
    end
  end

  # `removed` and `added` are arrays of tag join ids that have been added or removed to a supporter
  def self.sync_supporters_to_list_from_tag_joins(npo_id, supporter_ids, tag_data)
    emails = get_emails_for_supporter_ids(npo_id, supporter_ids)
    to_add = get_mailchimp_list_ids(tag_data.selected.to_tag_master_ids)
    to_remove = get_mailchimp_list_ids(tag_data.unselected.to_tag_master_ids)
    return if to_add.empty? && to_remove.empty?

    bulk_post = emails.map { |em| to_add.map { |ml_id| {method: "POST", path: "lists/#{ml_id}/members", body: {email_address: em, status: "subscribed"}.to_json} } }.flatten
    bulk_delete = emails.map { |em| to_remove.map { |ml_id| {method: "DELETE", path: "lists/#{ml_id}/members/#{Digest::MD5.hexdigest(em.downcase)}"} } }.flatten
    perform_batch_operations(npo_id, bulk_post.concat(bulk_delete))
  end

  def self.get_emails_for_supporter_ids(npo_id, supporters_ids = [])
    Nonprofit.find(npo_id).supporters.where("id in (?)", supporters_ids).pluck(:email).select(&:present?)
  end

  def self.get_mailchimp_list_ids(tag_master_ids)
    return [] if tag_master_ids.empty?
    Qx.select("email_lists.mailchimp_list_id")
      .from(:tag_masters)
      .where("tag_masters.id IN ($ids)", ids: tag_master_ids)
      .join("email_lists", "email_lists.tag_master_id=tag_masters.id")
      .execute.map { |h| h["mailchimp_list_id"] }
  end

  # @param [Nonprofit] nonprofit
  # @param [Boolean] delete_from_mailchimp do you want to delete extra items on mailchimp, defaults to false
  def self.hard_sync_lists(nonprofit, delete_from_mailchimp = false)
    return if !nonprofit

    nonprofit.tag_masters.not_deleted.each do |i|
      if i.email_list
        hard_sync_list(i.email_list, delete_from_mailchimp)
      end
    end
  end

  def self.sync_nonprofit_users
    User.nonprofit_personnel.find_each do |np_user|
      MailchimpNonprofitUserAddJob.perform_later(np_user, np_user.roles.nonprofit_personnel.first.host)
    end
  end

  # @param [EmailList] email_list
  # @param [Boolean] delete_from_mailchimp do you want to delete extra items on mailchimp, defaults to false
  def self.hard_sync_list(email_list, delete_from_mailchimp = false)
    ops = generate_batch_ops_for_hard_sync(email_list, delete_from_mailchimp)
    perform_batch_operations(email_list.nonprofit.id, ops)
  end

  # @param [Boolean] delete_from_mailchimp do you want to delete extra items on mailchimp, defaults to false
  def self.generate_batch_ops_for_hard_sync(email_list, delete_from_mailchimp = false)
    # get the subscribers from mailchimp
    mailchimp_subscribers = get_list_mailchimp_subscribers(email_list)
    # get our subscribers
    our_supporters = email_list.tag_master.tag_joins.map { |i| i.supporter }

    # split them as follows:
    # on both lists, on our list, on the mailchimp list
    _, in_mailchimp_only = mailchimp_subscribers.partition do |mc_sub|
      our_supporters.any? { |s| s.email.downcase == mc_sub[:email_address].downcase }
    end

    _, in_our_side_only = our_supporters.partition do |s|
      mailchimp_subscribers.any? { |mc_sub| s.email.downcase == mc_sub[:email_address].downcase }
    end

    # if on our list, add to mailchimp
    output = in_our_side_only.map { |i|
      {method: "POST", path: "lists/#{email_list.mailchimp_list_id}/members", body: create_subscribe_body(i).to_json}
    }

    if delete_from_mailchimp
      # if on mailchimp list, delete from mailchimp
      output = output.concat(in_mailchimp_only.map { |i| {method: "DELETE", path: "lists/#{email_list.mailchimp_list_id}/members/#{i[:id]}"} })
    end

    output
  end

  def self.get_list_mailchimp_subscribers(email_list)
    mailchimp_token = get_mailchimp_token(email_list.tag_master.nonprofit.id)
    uri = base_uri(mailchimp_token)
    result = get(uri + "/lists/#{email_list.mailchimp_list_id}/members?count=1000000000", {
      basic_auth: {username: @username, password: mailchimp_token},
      headers: {"Content-Type" => "application/json"}
    })
    result["members"].map do |i|
      {id: i["id"], email_address: i["email_address"]}
    end.to_a
  end

  def self.get_email_lists(nonprofit)
    mailchimp_token = get_mailchimp_token(nonprofit.id)
    uri = base_uri(mailchimp_token)
    result = get(uri + "/lists?count=1000000000", {
      basic_auth: {username: @username, password: mailchimp_token},
      headers: {"Content-Type" => "application/json"}
    })
    result["lists"]
  end

  def self.get_list(nonprofit, list_id)
    mailchimp_token = get_mailchimp_token(nonprofit.id)
    uri = base_uri(mailchimp_token)
    get(uri + "/lists/#{list_id}", {
      basic_auth: {username: @username, password: mailchimp_token},
      headers: {"Content-Type" => "application/json"}
    })
  end

  def self.create_nonprofit_user_subscribe_body(nonprofit, user)
    JSON.parse(ApplicationController.render("mailchimp/nonprofit_user_subscribe", assigns: {nonprofit: nonprofit, user: user}))
  end

  def self.create_subscribe_body(supporter)
    JSON.parse(ApplicationController.render("mailchimp/list", assigns: {supporter: supporter}))
  end

  def self.generate_list_member_path(list_members_path, email)
    list_members_path + "/" + Digest::MD5.hexdigest(email.downcase)
  end
end
