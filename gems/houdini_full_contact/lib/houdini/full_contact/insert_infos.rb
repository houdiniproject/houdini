# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "qx"
require "rest-client"
module Houdini::FullContact::InsertInfos
  # Fetch and persist a single full contact record for a single supporter
  # return an exception if 404 or something else went poop
  # @param supporter Supporter
  def self.single(supporter)
    return if supporter.nil? || supporter.email.blank?
    begin
      response = RestClient.post("https://api.fullcontact.com/v3/person.enrich",
        {
          "email" => supporter.email
        }.to_json,
        {
          :authorization => "Bearer #{Houdini::FullContact.api_key}",
          "Reporting-Key" => supporter.nonprofit_id
        })
      result = response.parsed_body
    rescue RestClient::NotFound
      # this means there's no information about this contact so there's nothing to do.
      # We just return and end

      # NOTE: We pass on other errors because that means something failed. *shrug*
      return
    end

    location = result["location"] && result["details"]["locations"] && result["details"]["locations"][0]
    existing = supporter.full_contact_infos.last
    info_data = {
      full_name: result["fullName"],
      gender: result["gender"],
      city: location && location["city"],
      state_code: location && location["regionCode"],
      country: location && location["countryCode"],
      age_range: result["ageRange"],
      location_general: result["location"],
      websites: ((result["details"] && result["details"]["urls"]) || []).map { |h| h["value"] }.join(","),
      supporter_id: supporter.id
    }
    return {
      "full_contact_info" => full_contact_info,
      "full_contact_photos" => full_contact_photos,
      "full_contact_social_profiles" => full_contact_social_profiles,
      "full_contact_orgs" => full_contact_orgs
    }

    full_contact_info = if existing
      Qx.update(:full_contact_infos)
        .set(info_data)
        .timestamps
        .where(id: existing["id"])
        .returning("*")
        .execute.first
    else
      Qx.insert_into(:full_contact_infos)
        .values(info_data)
        .returning("*")
        .timestamps
        .execute.first
    end

    if result["details"]["photos"].present?
      photo_data = result["details"]["photos"].map { |h| {type_id: h["label"], url: h["value"]} }
      Qx.delete_from("full_contact_photos")
        .where(full_contact_info_id: full_contact_info["id"])
        .execute
      full_contact_photos = Qx.insert_into(:full_contact_photos)
        .values(photo_data)
        .common_values(full_contact_info_id: full_contact_info["id"])
        .timestamps
        .returning("*")
        .execute
    end

    if result["details"]["profiles"].present?
      profile_data = result["details"]["profiles"].map { |k, v| {type_id: v["service"], username: v["username"], uid: v["userid"], bio: v["bio"], url: v["url"], followers: v["followers"], following: v["following"]} }
      Qx.delete_from("full_contact_social_profiles")
        .where(full_contact_info_id: full_contact_info["id"])
        .execute
      full_contact_social_profiles = Qx.insert_into(:full_contact_social_profiles)
        .values(profile_data)
        .common_values(full_contact_info_id: full_contact_info["id"])
        .timestamps
        .returning("*")
        .execute
    end

    if result["details"].present? && result["details"]["employment"].present?
      Qx.delete_from("full_contact_orgs")
        .where(full_contact_info_id: full_contact_info["id"])
        .execute
      org_data = result["details"]["employment"].map { |h|
        start_date = h["start"] && [h["start"]["year"], h["start"]["month"], h["start"]["day"]].select(&:present?).join("-")
        end_date = h["end"] && [h["end"]["year"], h["end"]["month"], h["end"]["day"]].select(&:present?).join("-")
        {
          name: h["name"],
          start_date: start_date,
          end_date: end_date,
          title: h["title"],
          current: h["current"]
        }
      }
        .map { |h|
        h[:end_date] = Format::Date.parse_partial_str(h[:end_date])
        h
      }
        .map { |h|
        h[:start_date] = Format::Date.parse_partial_str(h[:start_date])
        h
      }

      full_contact_orgs = Qx.insert_into(:full_contact_orgs)
        .values(org_data)
        .common_values(full_contact_info_id: full_contact_info["id"])
        .timestamps
        .returning("*")
        .execute
    end

    {
      "full_contact_info" => full_contact_info,
      "full_contact_photos" => full_contact_photos,
      "full_contact_social_profiles" => full_contact_social_profiles,
      "full_contact_orgs" => full_contact_orgs
    }
  end

  # Delete all orphaned full contact infos that do not have supporters
  # or full_contact photos, social_profiles, topics, orgs, etc that do not have a parent info
  def self.cleanup_orphans
    Info.includes(:supporter).where("supporters.id IS NULL").delete_all
    Photo.includes(:full_contact_infos).where("full_contact_infos.id IS NULL").delete_all
    SocialProfiles.includes(:full_contact_infos).where("full_contact_infos.id IS NULL").delete_all
    Topics.includes(:full_contact_infos).where("full_contact_infos.id IS NULL").delete_all
    Orgs.includes(:full_contact_infos).where("full_contact_infos.id IS NULL").delete_all
  end
end
