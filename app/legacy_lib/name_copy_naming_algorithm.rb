# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class NameCopyNamingAlgorithm < CopyNamingAlgorithm
  attr_accessor :klass, :nonprofit_id
  # @param [Class] klass
  def initialize(klass, nonprofit_id)
    @klass = klass
    @nonprofit_id = nonprofit_id
  end

  def copy_addition
    " (#{Time.now.strftime("%F")} copy)"
  end

  def separator_before_copy_number
    " "
  end

  def max_copies
    30
  end

  def max_length
    CreateCampaign::CAMPAIGN_NAME_LENGTH_LIMIT
  end

  def get_name_for_entity(name_entity)
    name_entity.name
  end

  def get_already_used_name_entities(base_name)
    end_name = "#{copy_addition.gsub("(", '\\(').gsub(")", '\\)')} \\d{2}"
    end_name_length = copy_addition.length + 3
    amount_to_strip = end_name_length + base_name.length - max_length
    amount_to_strip = 0 if amount_to_strip < 0
    @klass.method(:where).call("name SIMILAR TO ? AND nonprofit_id = ? AND (deleted IS NULL OR deleted = false)", "#{base_name[0..base_name.length - amount_to_strip - 1]}_*" + end_name, nonprofit_id).select("name")
  end
end
