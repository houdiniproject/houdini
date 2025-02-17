# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module CreateCustomFieldJoin
  def self.create(supporter, _profile_id, params)
    supporter.custom_field_joins.create(params)
  end

  # In the future, this should create an activity feed entry

  # @param [Array<Hash>] custom_fields Hash with following keys:
  #                * custom_field_definition_id [Integer] for the key corresponding to custom_field_definition_id
  #                * value [Object] the expected value of the field. If this key is an empty string, we remove the custom_field

  def self.modify(np, user, supporter_ids, custom_fields)
    return if supporter_ids.nil? || supporter_ids.empty?
    return if custom_fields.nil? || custom_fields.empty?

    supporter_ids.each do |sid|
      supporter = np.supporters.find(sid)
      custom_fields.each do |custom_field|
        existing = supporter.custom_field_joins.find_by_custom_field_definition_id(custom_field[:custom_field_definition_id])
        if existing
          existing.update(
            custom_field_definition_id: custom_field[:custom_field_definition_id],
            value: custom_field[:value]
          )
        else
          create(supporter, user.profile.id,
            custom_field_definition_id: custom_field[:custom_field_definition_id],
            value: custom_field[:value])
        end
      end
    end
    np
  end
end
