# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SlugNonprofitNamingAlgorithm < CopyNamingAlgorithm
  attr_accessor :state_slug, :city_slug

  def initialize(state_slug, city_slug)
    @state_slug = state_slug
    @city_slug = city_slug
  end

  def copy_addition
    ""
  end

  def max_copies
    99
  end

  def separator_before_copy_number
    "-"
  end

  def get_name_for_entity(name_entity)
    name_entity.slug
  end

  def get_already_used_name_entities(base_name)
    end_name = '\\-\\d{2}'
    Nonprofit.method(:where).call("slug SIMILAR TO ?  AND state_code_slug = ? AND city_slug = ?", base_name + end_name, @state_slug, @city_slug).select("slug")
  end
end
