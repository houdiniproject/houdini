# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Describes a single requested modification to the list of tags on a supporter
class TagJoin::Modification
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :tag_master_id, :integer
  attribute :selected, :boolean, default: false

  def initialize(opts={})
    super(opts)
  end

  def tag_master
    TagMaster.find(tag_master_id)
  end

end