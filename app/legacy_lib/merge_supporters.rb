# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MergeSupporters
  # For supporters that have been merged, we want to update all their child tables to the new supporter_id
  def self.update_associations(old_supporters, new_supporter, np_id, profile_id)
    new_supporter_id = new_supporter.id
    old_supporter_ids = old_supporters.map { |i| i.id }
    # The new supporter needs to have the following tables from the merged supporters:
    associations = [:activities, :donations, :recurring_donations, :offsite_payments, :payments, :tickets, :supporter_notes, :supporter_emails, :full_contact_infos]

    associations.each do |table_name|
      Qx.update(table_name)
        .set(supporter_id: new_supporter_id)
        .where("supporter_id IN ($ids)", ids: old_supporter_ids).timestamps.execute
    end

    old_supporters.joins(:cards).each do |supp|
      supp.cards.each do |card|
        card.holder = new_supporter
        card.save!
      end
    end

    old_supporters = old_supporters.includes(:tag_joins).includes(:custom_field_joins)
    old_tags = old_supporters.map { |i| i.tag_joins.map { |j| j.tag_master } }.flatten.uniq

    # delete old tags
    InsertTagJoins.in_bulk(np_id, profile_id, old_supporter_ids,
      old_tags.map { |i| {tag_master_id: i.id, selected: false} })

    InsertTagJoins.in_bulk(np_id, profile_id, [new_supporter_id], old_tags.map { |i| {tag_master_id: i.id, selected: true} })

    all_custom_field_joins = old_supporters.map { |i| i.custom_field_joins }.flatten
    group_joins_by_custom_field_master = all_custom_field_joins.group_by { |i| i.custom_field_master.id }
    one_custom_field_join_per_user = group_joins_by_custom_field_master.map { |k, v|
      v.sort_by { |i|
        i.created_at
      }.last
    }

    # delete old supporter custom_field
    InsertCustomFieldJoins.in_bulk(np_id, old_supporter_ids, one_custom_field_join_per_user.map { |i|
      {
        custom_field_master_id: i.custom_field_master_id,
        value: ""
      }
    })

    # insert new supporter custom field
    InsertCustomFieldJoins.in_bulk(np_id, [new_supporter_id], one_custom_field_join_per_user.map { |i|
      {
        custom_field_master_id: i.custom_field_master_id,
        value: i.value
      }
    })

    # Update all deleted/merged supporters to record when and where they got merged
    Psql.execute(Qexpr.new.update(:supporters, {merged_at: Time.current, merged_into: new_supporter_id}).where("id IN ($ids)", ids: old_supporter_ids))
    # Removing any duplicate custom fields UpdateCustomFieldJoins.delete_dupes([new_supporter_id])
  end

  def self.selected(merged_data, supporter_ids, np_id, profile_id, skip_conflicting_custom_fields = false)
    old_supporters = Nonprofit.find(np_id).supporters.where("supporters.id IN (?)", supporter_ids)

    if skip_conflicting_custom_fields && conflicting_custom_fields?(old_supporters)
      return {json: supporter_ids, status: :failure}
    end

    merged_data["anonymous"] = old_supporters.any? { |i| i.anonymous }
    new_supporter = Nonprofit.find(np_id).supporters.create!(merged_data)
    # Update merged supporters as deleted
    Psql.execute(Qexpr.new.update(:supporters, {deleted: true}).where("supporters.id IN ($ids)", ids: supporter_ids))
    # Update all associated tables
    update_associations(old_supporters, new_supporter, np_id, profile_id)
    {json: new_supporter, status: :ok}
  end

  def self.conflicting_custom_fields?(supporters)
    cfjs = []
    supporters.each do |supporter|
      supporter.custom_field_joins.each do |cfj|
        cfjs << {"custom_field_master_id" => cfj.custom_field_master_id, "value" => cfj.value}
      end
    end

    cfjs.group_by { |i| i["custom_field_master_id"] }.any? { |id, group| group.uniq.size > 1 }
  end

  # Merge supporters for a nonprofit based on an array of groups of ids, generated from QuerySupporters.dupes_on_email or dupes_on_names
  # @return [Array[Array]] an array of arrays of supporter_ids that have conflicting custom fields between them.
  def self.merge_by_id_groups(np_id, arr_of_ids, profile_id, skip_conflicting_custom_fields = false)
    supporter_ids_with_conflicting_custom_fields = []
    arr_of_ids.select { |arr| arr.count > 1 }.each do |ids|
      Qx.transaction do
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
        end.merge({"nonprofit_id" => np_id})

        result = MergeSupporters.selected(data, ids, np_id, profile_id, skip_conflicting_custom_fields)
        supporter_ids_with_conflicting_custom_fields << ids if result[:status] == :failure

        # Create supporter.created object event
        Supporter.find(ids.first).merged_into&.publish_created
      end
    end
    supporter_ids_with_conflicting_custom_fields
  end
end
