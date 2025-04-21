# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SlugCopyNamingAlgorithm < CopyNamingAlgorithm
  attr_accessor :klass, :nonprofit_id
  # @param [Class] klass
  def initialize(klass, nonprofit_id)
    @klass = klass
    @nonprofit_id = nonprofit_id
  end

  def copy_addition
    "_copy"
  end

  def max_copies
    30
  end

  def get_name_for_entity(name_entity)
    name_entity.slug
  end

  def get_already_used_name_entities(base_name)
    end_name = '\\_copy\\_\\d{2}'
    @klass.method(:where).call("slug SIMILAR TO ? AND nonprofit_id = ? AND (deleted IS NULL OR deleted = false)", base_name + end_name, nonprofit_id).select("slug")
  end
end
