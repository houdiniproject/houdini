# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Handy class managing a list of requested modifications
class TagJoin::Modifications < Array

  # accepts an Array containing hashes with the keys `tag_master_id`` and `selected` or `TagJoin::Modification`'s
  def initialize(tag_modifications_source=[])
    super(tag_modifications_source.map do |i|
      i.is_a?(TagJoin::Modification) ? i : TagJoin::Modification.new(i)
    end
    )
  end

  # @return [TagJoin::Modifications] all tags which are selected
  def selected
    TagJoin::Modifications.new(self.select{|i| i.selected})
  end

  # @return [TagJoin::Modifications] all tags which are not selected
  def unselected
    TagJoin::Modifications.new(self.select{|i| !i.selected})
  end

  # @return [integer] the TagMaster ids of all of the referenced tags
  def to_tag_master_ids
    self.map{|i| i.tag_master_id}
  end

  # given a set of ids for TagMaster OR TagMaster objects themeselves,
  # returns a TagJoin::Modifications with the TagJoin::Modification's which
  # have a corresponding id
  # @param [Array<TagMaster|integer>] tags a list of TagMaster or ids for TagMasters to match against
  # @return [TagJoin::Modification] TagJoin::Modification with all modifications which matches the passed in list
  # @example passing in a TagMaster
  #   given_tag_master = TagMaster.find(1234)
  #   modifications = TagJoin::Modifications.new([{tag_master_id: 5678, selected: true}, {tag_master_id: 1234, selected: false}])
  # 
  #   mods_for_tags = modifications.for_given_tags([given_tag_master])
  #   # => [#<TagJoin::Modification:0x0000560dd9929c20 @selected=false, @tag_master_id=1234>]
  #
  #
  def for_given_tags(tags=[])
    valid_ids = tags.map do |i|
      if (i.is_a? Integer)
        i
      else
        i.id
      end
    end

    TagJoin::Modifications.new(self.select{|i| valid_ids.include? i.tag_master_id})
  end

end