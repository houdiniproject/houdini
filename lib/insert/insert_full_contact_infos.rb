# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'

module InsertFullContactInfos


  # Work off of the full_contact_jobs queue
  def self.work_queue
    ids = Qx.select('supporter_id').from('full_contact_jobs').ex.map{|h| h['supporter_id']}
    Qx.delete_from('full_contact_jobs').where('TRUE').execute
    self.bulk(ids) if ids.any?
  end


  # Enqueue full contact jobs for a set of supporter ids
  def self.enqueue(supporter_ids)
    Qx.insert_into(:full_contact_jobs)
      .values(supporter_ids.map{|id| {supporter_id: id}})
      .ex
  end


  # We need to throttle our requests by 10ms since that is our rate limit on FullContact
  def self.bulk(supporter_ids)
    created_ids = []
    supporter_ids.each do |id|
      now = Time.current
      result = InsertFullContactInfos.single id
      created_ids.push(GetData.hash(result, 'full_contact_info', 'id')) if result.is_a?(Hash)
      interval = 0.1 - (Time.current - now) # account for time taken in .single
      sleep interval if interval > 0
    end
    return created_ids
  end
  

  # Fetch and persist a single full contact record for a single supporter
  # return an exception if 404 or something else went poop
  def self.single(supporter_id)
    supp = Qx.select('email').from('supporters').where(id: supporter_id).execute.first
    return if supp.nil? || supp['email'].blank?

    begin
      result = FullContact.person(email: supp['email']).to_h
    rescue Exception => e
      return e
    end

    if result['status'] == 202 # Queued for search
      # self.enqueue([supporter_id])
      return result
    end

    existing = Qx.select('id').from('full_contact_infos').where(supporter_id: supporter_id).ex.first
    info_data = {
      full_name: GetData.hash(result, 'contact_info', 'full_name'),
      gender: GetData.hash(result, 'demographics', 'gender'),
      city: GetData.hash(result, 'demographics', 'location_deduced', 'city', 'name'),
      county: GetData.hash(result, 'demographics', 'location_deduced', 'county', 'name'),
      state_code: GetData.hash(result, 'demographics', 'location_deduced', 'state', 'code'),
      country: GetData.hash(result, 'demographics', 'location_deduced', 'country', 'name'),
      continent: GetData.hash(result, 'demographics', 'location_deduced', 'continent', 'name'),
      age: GetData.hash(result, 'demographics', 'age'),
      age_range: GetData.hash(result, 'demographics', 'age_range'),
      location_general: GetData.hash(result, 'demographics', 'location_general'),
      websites: (GetData.hash(result, 'contact_info', 'websites') || []).map{|h| h.url}.join(','),
      supporter_id: supporter_id
    }

    if existing
      full_contact_info = Qx.update(:full_contact_infos)
        .set(info_data)
        .timestamps
        .where(id: existing['id'])
        .returning('*')
        .execute.first
    else
      full_contact_info = Qx.insert_into(:full_contact_infos)
        .values(info_data)
        .returning('*')
        .timestamps
        .execute.first
    end

    if result['photos'].present?
      photo_data = result['photos'].map{|h| {type_id: h.type_id, url: h.url, is_primary: h.is_primary}}
      Qx.delete_from("full_contact_photos")
        .where(full_contact_info_id: full_contact_info['id'])
        .execute
      full_contact_photos = Qx.insert_into(:full_contact_photos)
        .values(photo_data)
        .common_values(full_contact_info_id: full_contact_info['id'])
        .timestamps
        .returning("*")
        .execute
    end

    if result['social_profiles'].present?
      profile_data = result['social_profiles'].map{|h| {type_id: h.type_id, username: h.username, uid: h.id, bio: h.bio, url: h.url, followers: h.followers, following: h.following} }
      Qx.delete_from("full_contact_social_profiles")
        .where(full_contact_info_id: full_contact_info['id'])
        .execute
      full_contact_social_profiles = Qx.insert_into(:full_contact_social_profiles)
        .values(profile_data)
        .common_values(full_contact_info_id: full_contact_info['id'])
        .timestamps
        .returning("*")
        .execute
    end

    if result['digital_footprint'] && result['digital_footprint']['topics'].present?
      profile_data = result['social_profiles']
        .map{|h| {
          type_id: h.type_id,
          username: h.username,
          uid: h.id,
          bio: h.bio,
          url: h.url,
          followers: h.followers,
          following: h.following
        } }
      
      vals = result['digital_footprint']['topics'].map{|h| h.value}
      existing_vals = Qx.select('value').from('full_contact_topics')
        .where("value IN ($vals)", vals: vals)
        .and_where("full_contact_info_id=$id", id: full_contact_info['id'])
        .execute.map{|h| h['value']}

      topic_data = result['digital_footprint']['topics']
        .reject{|h| existing_vals.include?(h.value)}
        .map{|h| {value: h.value, provider: h.provider}}

      if topic_data.any?
        full_contact_topics = Qx.insert_into(:full_contact_topics)
          .values(topic_data)
          .common_values(full_contact_info_id: full_contact_info['id'])
          .timestamps
          .returning('*')
          .execute
      end
    end


    if result['organizations'].present?
      Qx.delete_from('full_contact_orgs')
        .where(full_contact_info_id: full_contact_info['id'])
        .execute
      org_data = result['organizations'].map{|h| {
          is_primary: h.is_primary,
          name: h.name,
          start_date: h.start_date,
          end_date: h.end_date,
          title: h.title,
          current: h.current
        } }
        .map{|h| h[:end_date] = Format::Date.parse_partial_str(h[:end_date]); h}
        .map{|h| h[:start_date] = Format::Date.parse_partial_str(h[:start_date]); h}

      full_contact_orgs = Qx.insert_into(:full_contact_orgs)
        .values(org_data)
        .common_values(full_contact_info_id: full_contact_info['id'])
        .timestamps
        .returning('*')
        .execute
    end

    return {
      'full_contact_info' => full_contact_info,
      'full_contact_photos' => full_contact_photos,
      'full_contact_social_profiles' => full_contact_social_profiles,
      'full_contact_topics' => full_contact_topics,
      'full_contact_orgs' => full_contact_orgs
    }
  end

  # Delete all orphaned full contact infos that do not have supporters
  # or full_contact photos, social_profiles, topics, orgs, etc that do not have a parent info
  def self.cleanup_orphans
    Qx.delete_from("full_contact_infos")
      .where("id IN ($ids)", ids: Qx.select("full_contact_infos.id")
        .from("full_contact_infos")
        .left_join("supporters", "full_contact_infos.supporter_id=supporters.id")
        .where("supporters.id IS NULL")
      ).ex 
    Qx.delete_from("full_contact_photos")
      .where("id IN ($ids)", ids: Qx.select("full_contact_photos.id")
        .from("full_contact_photos")
        .left_join("full_contact_infos", "full_contact_infos.id=full_contact_photos.full_contact_info_id")
        .where("full_contact_infos.id IS NULL")
      ).ex
    Qx.delete_from("full_contact_social_profiles")
      .where("id IN ($ids)", ids: Qx.select("full_contact_social_profiles.id")
        .from("full_contact_social_profiles")
        .left_join("full_contact_infos", "full_contact_infos.id=full_contact_social_profiles.full_contact_info_id")
        .where("full_contact_infos.id IS NULL")
      ).ex
    Qx.delete_from("full_contact_topics")
      .where("id IN ($ids)", ids: Qx.select("full_contact_topics.id")
        .from("full_contact_topics")
        .left_join("full_contact_infos", "full_contact_infos.id=full_contact_topics.full_contact_info_id")
        .where("full_contact_infos.id IS NULL")
      ).ex
    Qx.delete_from("full_contact_orgs")
      .where("id IN ($ids)", ids: Qx.select("full_contact_orgs.id")
        .from("full_contact_orgs")
        .left_join("full_contact_infos", "full_contact_infos.id=full_contact_orgs.full_contact_info_id")
        .where("full_contact_infos.id IS NULL")
      ).ex
  end
end
