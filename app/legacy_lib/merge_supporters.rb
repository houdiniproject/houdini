# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module MergeSupporters
  # For supporters that have been merged, we want to update all their child tables to the new supporter_id
  def self.update_associations(old_supporter_ids, new_supporter_id, np_id, profile_id)
    # The new supporter needs to have the following tables from the merged supporters:
    associations = %i[activities donations recurring_donations offsite_payments payments tickets supporter_notes full_contact_infos]

    associations.each do |table_name|
      Qx.update(table_name).set(supporter_id: new_supporter_id).where("supporter_id IN ($ids)", ids: old_supporter_ids).timestamps.execute
    end

    old_supporters = Supporter.includes(:tag_joins).includes(:custom_field_joins).where("id in (?)", old_supporter_ids)
    old_tags = old_supporters.map { |i| i.tag_joins.map(&:tag_definition) }.flatten.uniq

    # delete old tags
    InsertTagJoins.in_bulk(np_id, profile_id, old_supporter_ids,
      old_tags.map { |i| {tag_definition_id: i.id, selected: false} })

    InsertTagJoins.in_bulk(np_id, profile_id, [new_supporter_id], old_tags.map { |i| {tag_definition_id: i.id, selected: true} })

    all_custom_field_joins = old_supporters.map(&:custom_field_joins).flatten
    group_joins_by_custom_field_definition = all_custom_field_joins.group_by { |i| i.custom_field_definition.id }
    one_custom_field_join_per_user = group_joins_by_custom_field_definition.map do |_k, v|
      v.sort_by(&:created_at).last
    end

    # delete old supporter custom_field
    InsertCustomFieldJoins.in_bulk(np_id, old_supporter_ids, one_custom_field_join_per_user.map do |i|
                                                               {
                                                                 custom_field_definition_id: i.custom_field_definition_id,
                                                                 value: ""
                                                               }
                                                             end)

    # insert new supporter custom field
    InsertCustomFieldJoins.in_bulk(np_id, [new_supporter_id], one_custom_field_join_per_user.map do |i|
                                                                {
                                                                  custom_field_definition_id: i.custom_field_definition_id,
                                                                  value: i.value
                                                                }
                                                              end)

    # Update all deleted/merged supporters to record when and where they got merged
    Psql.execute(Qexpr.new.update(:supporters, merged_at: Time.current, merged_into: new_supporter_id).where("id IN ($ids)", ids: old_supporter_ids))
    # Removing any duplicate custom fields UpdateCustomFieldJoins.delete_dupes([new_supporter_id])
  end

  def self.selected(merged_data, supporter_ids, np_id, profile_id)
    new_supporter = Supporter.new(merged_data)
    new_supporter.save!
    # Update merged supporters as deleted
    Psql.execute(Qexpr.new.update(:supporters, deleted: true).where("id IN ($ids)", ids: supporter_ids))
    # Update all associated tables
    update_associations(supporter_ids, new_supporter["id"], np_id, profile_id)
    {json: new_supporter, status: :ok}
  end

  # Merge supporters for a nonprofit based on an array of groups of ids, generated from QuerySupporters.dupes_on_email or dupes_on_names
  def self.merge_by_id_groups(np_id, arr_of_ids, profile_id)
    Qx.transaction do
      arr_of_ids.select { |arr| arr.count > 1 }.each do |ids|
        # Get all column data from every supporter
        all_data = Psql.execute(
          Qexpr.new.from(:supporters)
          .select(:email, :name, :phone, :address, :city, :state_code, :zip_code, :organization, :country, :created_at)
          .where("id IN ($ids)", ids: ids)
          .order_by("created_at ASC")
        )
        # Use the most recent non null/blank column data for the new supporter
        data = all_data.each_with_object({}) do |supp, acc|
          supp.except("created_at").each { |key, val| acc[key] = val unless val.blank? }
        end.merge("nonprofit_id" => np_id)

        MergeSupporters.selected(data, ids, np_id, profile_id)
      end
    end
  end
end
