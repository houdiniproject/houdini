 module MergeSupporters

  # Given some supporter ids, merge them together into a new supporter
  def self.selected(merged_data, supporter_ids)
    new_supporter = Psql.execute(Qexpr.new.insert(:supporters, merged_data).returning('*')).first
    # Update merged supporters as deleted
    Psql.execute(Qexpr.new.update(:supporters, {deleted: true}).where("id IN ($ids)", ids: supporter_ids))
    # Update all associated tables
    self.update_associations(supporter_ids, new_supporter['id'])
		return {json: new_supporter, status: :ok}
	end

  # For supporters that have been merged, we want to update all their child tables to the new supporter_id
  def self.update_associations(old_supporter_ids, new_supporter_id)
    # The new supporter needs to have the following tables from the merged supporters:
    associations = [:activities, :donations, :recurring_donations, :offsite_payments, :payments, :tickets, :custom_field_joins, :tag_joins, :supporter_notes, :supporter_emails, :full_contact_infos]
    
    associations.each do |table_name|
      Qx.update(table_name).set(supporter_id: new_supporter_id).where("supporter_id IN ($ids)", ids: old_supporter_ids).timestamps.execute
    end
    # Update all deleted/merged supporters to record when and where they got merged
    Psql.execute(Qexpr.new.update(:supporters, {merged_at: Time.current, merged_into: new_supporter_id}).where("id IN ($ids)", ids: old_supporter_ids))
    # Removing any duplicate custom fields
    UpdateCustomFieldJoins.delete_dupes([new_supporter_id])
  end


  # Merge supporters for a nonprofit based on an array of groups of ids, generated from QuerySupporters.dupes_on_email or dupes_on_names
  def self.merge_by_id_groups(np_id, arr_of_ids)
    Qx.transaction do
      arr_of_ids.select{|arr| arr.count > 1}.each do |ids|
        # Get all column data from every supporter
        all_data = Psql.execute(
          Qexpr.new.from(:supporters)
          .select(:email, :name, :phone, :address, :city, :state_code, :zip_code, :organization, :latitude, :longitude, :country, :created_at)
          .where("id IN ($ids)", ids: ids)
          .order_by("created_at ASC")
        )
        # Use the most recent non null/blank column data for the new supporter
        data = all_data.reduce({}) do |acc, supp| 
          supp.except('created_at').each{|key, val| acc[key] = val unless val.blank?}
          acc
        end.merge({'nonprofit_id' => np_id})

        MergeSupporters.selected(data, ids)
      end
    end
  end


end
