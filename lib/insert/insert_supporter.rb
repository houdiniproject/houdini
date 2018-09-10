# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'psql'
require 'qexpr'
require 'i18n'

module InsertSupporter

  def self.create_or_update(np_id, data={})
    data = data.with_indifferent_access
    ParamValidation.new(data.merge(np_id: np_id), {
      np_id: {required: true, is_integer: true}
    })

    Qx.transaction do
      np = Nonprofit.find(np_id)
      custom_fields = data['customFields']

      data['name'] = data['name'] ? data['name'].strip.downcase : ""
      data['email'] = data['email'] ? data['email'].strip.downcase : ""
      if (data['name'].empty? && data['name'].empty?)
        supporter = Supporter.create!(defaults(data).merge(nonprofit:np))
      end

      unless supporter
        supporter = np.supporters.not_deleted
            .where("trim(lower(supporters.name)) = ?
                    AND trim(lower(supporters.email)) = ?",
                   data['name'], data['email']
            ).first

        if supporter
          supporter.update_attributes(defaults(data))
        else
          supporter = Supporter.create!(defaults(data).merge(nonprofit:np))
        end
      end

      if custom_fields
        InsertCustomFieldJoins.find_or_create(np_id, [supporter.id],  custom_fields)
      end

      #GeocodeModel.delay.supporter(supporter['id'])
      InsertFullContactInfos.enqueue([supporter.id])

      return supporter
    end
  end


	def self.defaults(h)
    h = h.slice('name',
       'first_name',
        'last_name',
        'email',
        'phone',
        'organization',
        'anonymous',
        'profile_id')
    h = h.except('profile_id') unless h['profile_id'].present?
		if h['first_name'].present? || h['last_name'].present?
			h['name'] = h['first_name'] || h['last_name']
			if h['first_name'] && h['last_name']
				h['name'] = "#{h['first_name'].strip} #{h['last_name'].strip}"
			end
		end

    h['email_unsubscribe_uuid'] = SecureRandom.uuid


		return h
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
    tags = data.select{|key, val| key.match(/^tag_/)}.map{|key, val| key.gsub('tag_', '')}
    fields = data.select{|key, val| key.match(/^field_/)}.map{|key, val| [key.gsub('field_', ''), val]}
    supp_cols = data.select{|key, val| !key.match(/^field_/) && !key.match(/^tag_/)}
    supporter = create_or_update(np_id, supp_cols)

    InsertTagJoins.delay.find_or_create(np_id, [supporter['id']], tags) if tags.any?
    InsertCustomFieldJoins.delay.find_or_create(np_id, [supporter['id']], fields) if fields.any?

    return supporter
  end

end
