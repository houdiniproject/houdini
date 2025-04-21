# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertDuplicate
  def self.campaign(campaign_id, profile_id)
    ParamValidation.new({campaign_id: campaign_id, profile_id: profile_id},
      campaign_id: {required: true, is_integer: true},
      profile_id: {required: true, is_integer: true})
    campaign = Campaign.where("id = ?", campaign_id).first
    unless campaign
      raise ParamValidation::ValidationError.new("#{campaign_id} is not a valid campaign", key: :campaign_id)
    end

    profile = Profile.where("id = ?", profile_id).first
    unless profile
      raise ParamValidation::ValidationError.new("#{profile_id} is not a valid profile", key: :profile_id)
    end

    dupe = campaign.dup
    Qx.transaction do
      dupe.slug = SlugCopyNamingAlgorithm.new(Campaign, dupe.nonprofit.id).create_copy_name(dupe.slug)
      dupe.name = NameCopyNamingAlgorithm.new(Campaign, dupe.nonprofit.id).create_copy_name(dupe.name)
      if dupe.end_datetime && dupe.end_datetime.ago(7.days) < DateTime.now
        dupe.end_datetime = DateTime.now.since(7.days)
      end

      dupe.published = false

      dupe.save!

      dupe.main_image.attach(campaign.main_image.blob) if campaign.main_image.attached?

      dupe.background_image.attach(campaign.background_image.blob) if campaign.background_image.attached?

      InsertDuplicate.campaign_gift_options(campaign_id, dupe.id)
    end

    dupe
  end

  def self.event(event_id, profile_id)
    ParamValidation.new({event_id: event_id, profile_id: profile_id},
      event_id: {required: true, is_integer: true},
      profile_id: {required: true, is_integer: true})
    event = Event.where("id = ?", event_id).first
    unless event
      raise ParamValidation::ValidationError.new("#{event_id} is not a valid event", key: :event_id)
    end

    profile = Profile.where("id = ?", profile_id).first
    unless profile
      raise ParamValidation::ValidationError.new("#{profile_id} is not a valid profile", key: :profile_id)
    end

    dupe = event.dup
    Qx.transaction do
      dupe.slug = SlugCopyNamingAlgorithm.new(Event, dupe.nonprofit.id).create_copy_name(dupe.slug)
      dupe.name = NameCopyNamingAlgorithm.new(Event, dupe.nonprofit.id).create_copy_name(dupe.name)

      we_changed_start_time = false

      length_of_event = dupe.end_datetime - dupe.start_datetime
      if dupe.start_datetime.ago(7.days) < DateTime.now
        dupe.start_datetime = DateTime.now.since(7.days)
        we_changed_start_time = true
      end

      if we_changed_start_time && dupe.end_datetime
        dupe.end_datetime = dupe.start_datetime.since(length_of_event)
      end

      dupe.published = false

      dupe.save!

      dupe.main_image.attach(event.main_image.blob) if event.main_image.attached?

      dupe.background_image.attach(event.background_image.blob) if event.background_image.attached?

      InsertDuplicate.ticket_levels(event_id, dupe.id)
      InsertDuplicate.event_discounts(event_id, dupe.id)
    end
    dupe
  end

  # selects all gift options associated with old campaign
  # and inserts them and creates associations with a new campaign
  def self.campaign_gift_options(old_campaign_id, new_campaign_id)
    cgos = Qx.select("*")
      .from("campaign_gift_options")
      .where(campaign_id: old_campaign_id)
      .execute
      .map { |c| c.except("id", "created_at", "updated_at", "campaign_id") }

    if cgos.any?
      Qx.insert_into("campaign_gift_options")
        .values(cgos)
        .common_values(campaign_id: new_campaign_id)
        .ts
        .returning("*")
        .execute
    end
  end

  # selects all ticket levels associated with old event
  # and inserts them and creates associations with a new event
  def self.ticket_levels(old_event_id, new_event_id)
    tls = Qx.select("*")
      .from("ticket_levels")
      .where(event_id: old_event_id)
      .execute
      .map { |t| t.except("id", "created_at", "updated_at", "event_id") }

    if tls.any?
      Qx.insert_into("ticket_levels")
        .values(tls)
        .common_values(event_id: new_event_id)
        .ts
        .returning("*")
        .execute
    end
  end

  # selects all discounts associated with old event
  # and inserts them and creates associations with a new event
  def self.event_discounts(old_event_id, new_event_id)
    eds = Qx.select("*")
      .from("event_discounts")
      .where(event_id: old_event_id)
      .execute
      .map { |t| t.except("id", "created_at", "updated_at", "event_id") }

    if eds.any?
      Qx.insert_into("event_discounts")
        .values(eds)
        .common_values(event_id: new_event_id)
        .ts
        .returning("*")
        .execute
    end
  end
end
