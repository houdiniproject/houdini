# frozen_string_literal: true

require "rails_helper"

describe MergeSupporters do
  describe ".update_associations" do
    around do |e|
      Timecop.freeze(2020, 3, 4) do
        e.run
      end
    end
    # one unique tag for 1
    # one unique tag for 2
    # one common tag on both
    #
    # one unique custom field on 1
    # one unique custom field on 2
    # one common field on both and keep the value of the most common

    let(:np) { force_create(:nm_justice) }
    let(:old_supporter1) { force_create(:supporter, nonprofit: np) }
    let(:old_supporter2) { force_create(:supporter, nonprofit: np) }
    let(:new_supporter) { force_create(:supporter, nonprofit: np) }

    let(:supporter_note) { force_create(:supporter_note, supporter: old_supporter1, content: "feoatheoiath") }

    let(:tag_definition) { force_create(:tag_definition, nonprofit: np, name: "something") }
    let(:tag_definition2) { force_create(:tag_definition, nonprofit: np, name: "something2") }
    let(:tag_definition3) { force_create(:tag_definition, nonprofit: np, name: "something3") }

    let(:tag_on_1) { force_create(:tag_join, tag_definition: tag_definition, supporter_id: old_supporter1.id) }
    let(:tag_on_2) { force_create(:tag_join, tag_definition: tag_definition2, supporter_id: old_supporter2.id) }
    let(:tag_on_both) { [old_supporter1, old_supporter2].each { |i| force_create(:tag_join, tag_definition: tag_definition3, supporter_id: i.id) } }

    let(:custom_field_definition) { force_create(:custom_field_definition, nonprofit: np, name: "cfm1") }
    let(:custom_field_definition2) { force_create(:custom_field_definition, nonprofit: np, name: "cfm2") }
    let(:custom_field_definition3) { force_create(:custom_field_definition, nonprofit: np, name: "cfm3") }

    let(:cfj_on_1) { force_create(:custom_field_join, supporter: old_supporter1, custom_field_definition: custom_field_definition, value: "cfj_on_1") }
    let(:cfj_on_2) { force_create(:custom_field_join, supporter: old_supporter2, custom_field_definition: custom_field_definition2, value: "cfj_on_2") }
    let(:cfj_on_3) { force_create(:custom_field_join, supporter: old_supporter1, custom_field_definition: custom_field_definition3, value: "old_cfj") }
    let(:cfj_on_4) { force_create(:custom_field_join, supporter: old_supporter2, custom_field_definition: custom_field_definition3, value: "new_cfj", created_at: Time.now + 1.day) }

    let(:profile) { force_create(:profile) }

    before do
      np
      old_supporter1
      old_supporter2
      new_supporter
      supporter_note
    end

    it "merges everything properly with tags and cfjs on both" do
      tag_on_1
      tag_on_2
      tag_on_both
      cfj_on_1
      cfj_on_2
      cfj_on_3
      cfj_on_4
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter.id, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 3
      expect(new_supporter.tag_joins.map(&:tag_definition)).to contain_exactly(tag_definition, tag_definition2, tag_definition3)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 3
      expect(new_supporter.custom_field_joins.map(&:custom_field_definition)).to contain_exactly(custom_field_definition, custom_field_definition2, custom_field_definition3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition }.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition2 }.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition3 }.value).to eq cfj_on_4.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on first" do
      tag_on_1
      cfj_on_1
      cfj_on_3
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter.id, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map(&:tag_definition)).to contain_exactly(tag_definition)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map(&:custom_field_definition)).to contain_exactly(custom_field_definition, custom_field_definition3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition }.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition3 }.value).to eq cfj_on_3.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on second" do
      tag_on_2
      cfj_on_2
      cfj_on_4
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter.id, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map(&:tag_definition)).to contain_exactly(tag_definition2)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map(&:custom_field_definition)).to contain_exactly(custom_field_definition2, custom_field_definition3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition2 }.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_definition == custom_field_definition3 }.value).to eq cfj_on_4.value
      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on neighter" do
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter.id, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 0

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 0
      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end
  end
end
