# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertCustomFieldJoins
  # Bulk insert many field joins into many supporters
  # for every field name, find or create it for the nonprofit
  # field_data should be an array of arrays liks [['Company', 'Pixar'],
  # ['Shirt-size', 'Small']]
  def self.find_or_create(np_id, supporter_ids, field_data)
    ParamValidation.new({np_id: np_id, supporter_ids: supporter_ids, field_data: field_data},
      np_id: {
        required: true,
        is_integer: true
      },
      supporter_ids: {
        required: true,
        is_array: true,
        min_length: 1
      },
      field_data: {
        required: true,
        is_array: true,
        min_length: 1
      })

    # make sure the np exists
    np = Nonprofit.where("id = ? ", np_id).first
    unless np
      raise ParamValidation::ValidationError.new("#{np_id} is not a valid non-profit", key: :np_id)
    end

    # make sure the supporters_ids exist
    supporter_ids.each do |id|
      unless np.supporters.where("id = ?", id).exists?
        raise ParamValidation::ValidationError.new("#{id} is not a valid supporter for nonprofit #{np_id}", key: :supporter_ids)
      end
    end

    cfm_id_to_value = field_data.map do |name, value|
      cfm = CustomFieldDefinition.where("nonprofit_id = ? and name = ?", np_id, name).first
      Qx.transaction do
        cfm ||= CustomFieldDefinition.create!(nonprofit: np, name: name)
      end
      {custom_field_definition_id: cfm.id, value: value}
    end
    in_bulk(np_id, supporter_ids, cfm_id_to_value)
  end

  # Validation: *np_id is valid, corresponds to real nonprofit
  #
  #
  # @param [Integer] np_id nonprofit_id whose custom_fields this applies to
  # @param [Array<Integer>] supporter_ids the supporter ids in which the custom fields should be modified
  # @param [Array<Hash<Symbol, Object>>] field_data the fields you'd like to modify. Each item is a hash with following keys:
  #                * custom_field_definition_id [Integer] for the key corresponding to custom_field_definition_id
  #                * value [Object] the expected value of the field. If this key is an empty string, we remove the custom_field
  def self.in_bulk(np_id, supporter_ids, field_data)
    begin
      ParamValidation.new({
        np_id: np_id,
        supporter_ids: supporter_ids,
        field_data: field_data
      },
        np_id: {required: true, is_integer: true},
        supporter_ids: {required: true, is_array: true},
        field_data: {required: true, is_array: true})
    # array_of_hashes: {
    #   selected: {required: true}, tag_definition_id: {required: true, is_integer: true}
    # }
    rescue ParamValidation::ValidationError => e
      return {json: {error: "Validation error\n #{e.message}", errors: e.data}, status: :unprocessable_entity}
    end

    begin
      return {json: {error: "Nonprofit #{np_id} is not valid"}, status: :unprocessable_entity} unless Nonprofit.exists?(np_id)

      # verify that the supporters belong to the nonprofit
      supporter_ids = Supporter.where("nonprofit_id = ? and id IN (?)", np_id, supporter_ids).pluck(:id)
      unless supporter_ids.any?
        return {json: {inserted_count: 0, removed_count: 0}, status: :ok}
      end

      # filtering the tag_data to this nonprofit
      valid_ids = CustomFieldDefinition.where("nonprofit_id = ? and id IN (?)", np_id, field_data.map { |fd| fd[:custom_field_definition_id] }).pluck(:id).to_a
      filtered_field_data = field_data.select { |i| valid_ids.include? i[:custom_field_definition_id].to_i }

      # first, delete the items which should be removed
      to_insert, to_remove = filtered_field_data.partition do |t|
        !t[:value].blank?
      end
      deleted = []
      if to_remove.any?
        deleted = Qx.delete_from(:custom_field_joins)
          .where("supporter_id IN ($ids)", ids: supporter_ids)
          .and_where("custom_field_definition_id in ($fields)", fields: to_remove.map { |t| t[:custom_field_definition_id] })
          .returning("*")
          .execute
      end

      # next add only the selected tag_joins

      if to_insert.any?
        insert_data = supporter_ids.map { |id| to_insert.map { |cfm| {supporter_id: id, custom_field_definition_id: cfm[:custom_field_definition_id], value: cfm[:value]} } }.flatten
        cfj = Qx.insert_into(:custom_field_joins)
          .values(insert_data)
          .timestamps
          .on_conflict
          .conflict_columns(:supporter_id, :custom_field_definition_id).upsert(:custom_field_join_supporter_unique_idx)
          .returning("*")
          .execute
      else
        cfj = []
      end
    rescue ActiveRecord::ActiveRecordError => e
      return {json: {error: "A DB error occurred. Please contact support. \n #{e.message}"}, status: :unprocessable_entity}
    end

    # Create an activity for the modified tags for every supporter
    # TODO
    # activity_data = tags.map{|tag| {supporter_id: tag['supporter_id'], nonprofit_id: np_id, attachment_id: tag['id'], attachment_type: 'TagJoin', profile_id: profile_id}}
    # activities = Psql.execute( Qexpr.new.insert(:activities, activity_data) )

    # Sync mailchimp lists, if present
    # Mailchimp.delay.sync_supporters_to_list_from_tag_joins(np_id, supporter_ids, tag_data)

    {json: {inserted_count: cfj.count, removed_count: deleted.count}, status: :ok}
  end
end
