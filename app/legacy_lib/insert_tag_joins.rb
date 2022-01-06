# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertTagJoins
  # @param [Integer] np_id id for a [Nonprofit]
  # @param [Integer] profile_id id for the [Profile] corresponding to the current user. Not used currently but needed
  # @param [Array<Integer>] supporter_ids the ids of the all the supporters whose tags should be changed.
  # @param [Array<Hash>] tag_data a hashes consisting of the following keys:
  #                       * tag_definition_id: an [Integer] of the id of a tag in the database
  #                       * selected: a [Boolean] for whether to add the tag to the supporter (true) or remove (false)

  def self.in_bulk(np_id, profile_id, supporter_ids, tag_data)
    begin
      ParamValidation.new({
                            np_id: np_id,
                            profile_id: profile_id,
                            supporter_ids: supporter_ids,
                            tag_data: tag_data
                          },
                          np_id: { required: true, is_integer: true },
                          profile_id: { required: true, is_integer: true },
                          supporter_ids: { is_array: true },
                          tag_data: { required: true })
    # array_of_hashes: {
    #   selected: {required: true}, tag_definition_id: {required: true, is_integer: true}
    # }
    rescue ParamValidation::ValidationError => e
      return { json: { error: "Validation error\n #{e.message}", errors: e.data }, status: :unprocessable_entity }
    end

    begin
      return { json: { error: "Nonprofit #{np_id} is not valid" }, status: :unprocessable_entity } unless Nonprofit.exists?(np_id)
      return { json: { error: "Profile #{profile_id} is not valid" }, status: :unprocessable_entity } unless Profile.exists?(profile_id)

      # verify that the supporters belong to the nonprofit
      original_supporter_request = supporter_ids.count
      supporter_ids = Supporter.where('nonprofit_id = ? and id IN (?)', np_id, supporter_ids).pluck(:id)
      unless supporter_ids.any?
        return { json: { inserted_count: 0, removed_count: 0 }, status: :ok }
      end

      # filtering the tag_data to this nonprofit
      valid_ids = TagDefinition.where('nonprofit_id = ? and id IN (?)', np_id, tag_data.map { |tg| tg[:tag_definition_id] }).pluck(:id).to_a
      filtered_tag_data = tag_data.select { |i| valid_ids.include? i[:tag_definition_id].to_i }

      # first, delete the items which should be removed
      to_remove = filtered_tag_data.reject { |t| t[:selected] }.map { |t| t[:tag_definition_id] }
      deleted = []
      if to_remove.any?
        deleted = Qx.delete_from(:tag_joins)
                    .where('supporter_id IN ($ids)', ids: supporter_ids)
                    .and_where('tag_definition_id in ($tags)', tags: to_remove)
                    .returning('*')
                    .execute
      end

      # next add only the selected tag_joins
      to_insert = filtered_tag_data.select { |t| t[:selected] }.map { |t| t[:tag_definition_id] }
      insert_data = supporter_ids.map { |id| to_insert.map { |tag_definition_id| { supporter_id: id, tag_definition_id: tag_definition_id } } }.flatten
      if insert_data.any?
        tags = Qx.insert_into(:tag_joins)
                 .values(insert_data)
                 .timestamps
                 .on_conflict
                 .conflict_columns(:supporter_id, :tag_definition_id).upsert(:tag_join_supporter_unique_idx)
                 .returning('*')
                 .execute
      else
        tags = []
      end
    rescue ActiveRecord::ActiveRecordError => e
      return { json: { error: "A DB error occurred. Please contact support. \n #{e.message}" }, status: :unprocessable_entity }
    end

    # Create an activity for the modified tags for every supporter
    # TODO
    # activity_data = tags.map{|tag| {supporter_id: tag['supporter_id'], nonprofit_id: np_id, attachment_id: tag['id'], attachment_type: 'TagJoin', profile_id: profile_id}}
    # activities = Psql.execute( Qexpr.new.insert(:activities, activity_data) )

    # Sync mailchimp lists, if present
    MailchimpSupporterSyncJob.perform_later(np_id, supporter_ids, tag_data.as_json)

    { json: { inserted_count: tags.count, removed_count: deleted.count }, status: :ok }
  end

  # Find or create many tag names for every supporter
  # Creates tag definitions for tag names that are not present
  def self.find_or_create(np_id, supporter_ids, tag_names)
    # Pair each tag name with a tag definition id
    tags = tag_names.map do |name|
      tm = Qx.select(:id).from(:tag_definitions)
             .where(name: name)
             .and_where(nonprofit_id: np_id)
             .execute.last
      tm ||= Qx.insert_into(:tag_definitions).values(
        name: name,
        nonprofit_id: np_id
      ).ts.returning('id').execute.last
      [name, tm['id']]
    end

    tag_join_data = supporter_ids.map do |id|
      tags.map { |_name, tm_id| { supporter_id: id, tag_definition_id: tm_id } }
    end.flatten

    tag_joins = Qx.insert_into(:tag_joins)
                  .values(tag_join_data)
                  .ts.returning('id').execute

    tag_joins
  end

  private
end
