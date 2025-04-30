# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe TagJoin::Modification, type: :model do
  describe "#initialize" do
    it "works when nothing needs to be casted" do
      tag_master = create(:tag_master_base)
      expect(TagJoin::Modification.new(tag_master_id: tag_master.id, selected: false)).to have_attributes(
        tag_master_id: tag_master.id,
        selected: false,
        tag_master: tag_master
      )
    end

    it "works when it receives a ActionController::Parameters that is permitted" do
      tag_master = create(:tag_master_base)
      params = ActionController::Parameters.new(tag_master_id: tag_master.id, selected: false).permit(:tag_master_id, :selected)
      expect { TagJoin::Modification.new(params) }.to_not raise_error
    end

    it "works when everything needs to be casted" do
      tag_master = create(:tag_master_base)
      expect(TagJoin::Modification.new(tag_master_id: tag_master.id.to_s, selected: "false")).to have_attributes(
        tag_master_id: tag_master.id,
        selected: false,
        tag_master: tag_master
      )
    end
  end
end
