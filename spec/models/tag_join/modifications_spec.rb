# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe TagJoin::Modifications, type: :model do
  it "#initialize" do
    nonprofit = create(:nonprofit_base)
    tag_joins = [create(:tag_join_base, supporter: create(:supporter_base, nonprofit: nonprofit), tag_master: create(:tag_master_base, nonprofit: nonprofit))]

    expect(TagJoin::Modifications.new([{tag_master_id: tag_joins.first.tag_master_id, selected: "true"}])).to match(
      an_instance_of(TagJoin::Modifications).and(containing_exactly(
        an_instance_of(TagJoin::Modification).and(have_attributes(tag_master_id: tag_joins.first.tag_master_id, selected: true, tag_master: tag_joins.first.tag_master))
      ))
    )
  end

  it "#selected" do
    expect(TagJoin::Modifications.new([{tag_master_id: 1, selected: true}, {tag_master_id: 2, selected: false}]).selected).to match(
      an_instance_of(TagJoin::Modifications).and(containing_exactly(
        an_instance_of(TagJoin::Modification).and(have_attributes(tag_master_id: 1, selected: true))
      ))
    )
  end

  it "#unselected" do
    expect(TagJoin::Modifications.new([{tag_master_id: 1, selected: true}, {tag_master_id: 2, selected: false}]).unselected).to match(
      an_instance_of(TagJoin::Modifications).and(containing_exactly(
        an_instance_of(TagJoin::Modification).and(have_attributes(tag_master_id: 2, selected: false))
      ))
    )
  end

  describe "#for_given_tags" do
    it "gets correct tags when given integers" do
      expect(TagJoin::Modifications.new([{tag_master_id: 1, selected: true}, {tag_master_id: 2, selected: false}]).for_given_tags([4, 1])).to match(a_collection_containing_exactly(
        an_instance_of(TagJoin::Modification).and(have_attributes(tag_master_id: 1, selected: true))
      ))
    end

    it "gets correct tags when given TagMaster" do
      tag_master = create(:tag_master_base)
      expect(TagJoin::Modifications.new([{tag_master_id: tag_master.id, selected: true}, {tag_master_id: tag_master.id + 1, selected: false}]).for_given_tags([tag_master])).to match(a_collection_containing_exactly(
        an_instance_of(TagJoin::Modification).and(have_attributes(tag_master_id: tag_master.id, selected: true))
      ))
    end
  end
end
