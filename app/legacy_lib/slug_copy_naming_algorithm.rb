# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
    end_name = "\\_copy\\_\\d{2}"
    @klass.method(:where).call("slug SIMILAR TO ? AND nonprofit_id = ?", base_name + end_name, nonprofit_id).select("slug")
  end
end
