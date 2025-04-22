# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryFullContactInfos
  def self.fetch_associated_tables(fc_info_id)
    photo = Psql.execute(Qexpr.new.from(:full_contact_photos).select("url").where("full_contact_info_id = $id", id: fc_info_id).where("is_primary"))
    orgs = Psql.execute(Qexpr.new.from(:full_contact_orgs).select("current", "name", "title", "start_date", "end_date").where("full_contact_info_id = $id", id: fc_info_id).order_by("start_date DESC NULLS LAST"))
    topics = Psql.execute(Qexpr.new.from(:full_contact_topics).select("value").where("full_contact_info_id = $id", id: fc_info_id).order_by("value ASC"))
    profiles = Psql.execute(Qexpr.new.from(:full_contact_social_profiles).select("type_id", "followers", "url").where("full_contact_info_id = $id", id: fc_info_id).order_by("type_id ASC"))
    {
      photo: photo,
      topics: topics,
      orgs: orgs,
      profiles: profiles
    }
  end
end
