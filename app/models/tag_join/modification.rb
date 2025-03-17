# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Describes a single requested modification to the list of tags on a supporter
class TagJoin::Modification
  include ActiveModel::AttributeAssignment
  attr_reader :tag_master_id, :selected

  def initialize(opts={})
    assign_attributes(opts)
  end

  def tag_master_id=(value)
    @tag_master_id = cast_integer(value)
  end

  def selected=(value)
    @selected = cast_boolean(value)
  end

  def tag_master
    TagMaster.find(tag_master_id)
  end


  private

  def cast_boolean(value)
    ActiveRecord::Type::Boolean.new.cast(value)
  end

  def cast_integer(value)
    ActiveRecord::Type::Integer.new.cast(value)
  end
end