# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module InsertSupporter
  def self.create_or_update(np_id, data, update = false)
    if BLOCKED_SUPPORTERS.include?(data[:email])
      raise "Blocked supporter"
    end
    ParamValidation.new(data.merge(np_id: np_id), {
      np_id: {required: true, is_integer: true}
    })
    address_keys = ["name", "address", "city", "country", "state_code"]
    custom_fields = data["customFields"]
    tags = data["tags"]
    data = ActiveSupport::HashWithIndifferentAccess.new(Format::RemoveDiacritics.from_hash(data.to_deprecated_h, address_keys))
      .except(:customFields, :tags)
    nonprofit = Nonprofit.find(np_id)

    supporter = nonprofit.supporters.not_deleted.where("name = ? AND email = ?", data[:name], data[:email]).first
    if supporter && update
      supporter.update(data)
    else
      supporter = nonprofit.supporters.create(data)
      supporter.publish_created
    end

    InsertCustomFieldJoins.find_or_create(np_id, [supporter["id"]], custom_fields) if custom_fields.present?
    InsertTagJoins.find_or_create(np_id, [supporter["id"]], tags) if tags.present?

    supporter
  end

  # pass in a hash of supporter info, as well as
  # any property with tag_x will create a tag with name 'name'
  # any property with field_x will create a field with name 'x' and value set
  # eg:
  # {
  #   'name' => 'Bob Ross',
  #   'email' => 'bob@happytrees.org',
  #   'tag_xy' => true,
  #   'field_xy' => 420
  # }
  # The above will create a supporter with name/email, one tag with name 'xy',
  # and one field with name 'xy' and value 420
  def self.with_tags_and_fields(np_id, data)
    tags = data.select { |key, val| key.match(/^tag_/) }.map { |key, val| key.gsub("tag_", "") }
    fields = data.select { |key, val| key.match(/^field_/) }.map { |key, val| [key.gsub("field_", ""), val] }
    supp_cols = data.select { |key, val| !key.match(/^field_/) && !key.match(/^tag_/) }
    supporter = create_or_update(np_id, supp_cols)

    InsertTagJoins.delay.find_or_create(np_id, [supporter["id"]], tags) if tags.any?
    InsertCustomFieldJoins.delay.find_or_create(np_id, [supporter["id"]], fields) if fields.any?

    supporter
  end
end
