# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class SlugP2pCampaignNamingAlgorithm < CopyNamingAlgorithm

  attr_accessor :nonprofit_id
  # @param [Integer] nonprofit_id
  def initialize(nonprofit_id)
     @nonprofit_id = nonprofit_id
  end

  def copy_addition
    ""
  end

  def max_copies
    999
  end

  def get_name_for_entity(name_entity)
    name_entity.slug
  end

  def get_already_used_name_entities(base_name)
    end_name = "\\_\\d{3}"
    Campaign.where('slug SIMILAR TO ? AND nonprofit_id = ?', base_name + end_name, nonprofit_id).select('slug')
  end

end