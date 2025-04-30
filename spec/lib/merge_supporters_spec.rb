require "rails_helper"

describe MergeSupporters do
  let(:np) { force_create(:nonprofit) }
  let(:old_supporter1) { force_create(:supporter, nonprofit: np) }
  let(:old_supporter2) { force_create(:supporter, nonprofit: np) }
  let(:old_supporter3) { force_create(:supporter, nonprofit: np) }
  let(:card) { force_create(:card, holder: old_supporter1) }
  around(:each) do |e|
    StripeMockHelper.mock do
      Timecop.freeze(2020, 3, 4) do
        e.run
      end
    end
  end

  describe ".update_associations" do
    # one unique tag for 1
    # one unique tag for 2
    # one common tag on both
    #
    # one unique custom field on 1
    # one unique custom field on 2
    # one common field on both and keep the value of the most common

    let(:new_supporter) { force_create(:supporter, nonprofit: np) }

    let(:supporter_note) { force_create(:supporter_note, supporter: old_supporter1, content: "feoatheoiath") }

    let(:tag_master) { force_create(:tag_master, nonprofit: np, name: "something") }
    let(:tag_master2) { force_create(:tag_master, nonprofit: np, name: "something2") }
    let(:tag_master3) { force_create(:tag_master, nonprofit: np, name: "something3") }

    let(:tag_on_1) { force_create(:tag_join, tag_master: tag_master, supporter_id: old_supporter1.id) }
    let(:tag_on_2) { force_create(:tag_join, tag_master: tag_master2, supporter_id: old_supporter2.id) }
    let(:tag_on_both) { [old_supporter1, old_supporter2].each { |i| force_create(:tag_join, tag_master: tag_master3, supporter_id: i.id) } }

    let(:custom_field_master) { force_create(:custom_field_master, nonprofit: np, name: "cfm1") }
    let(:custom_field_master2) { force_create(:custom_field_master, nonprofit: np, name: "cfm2") }
    let(:custom_field_master3) { force_create(:custom_field_master, nonprofit: np, name: "cfm3") }

    let(:cfj_on_1) { force_create(:custom_field_join, supporter: old_supporter1, custom_field_master: custom_field_master, value: "cfj_on_1") }
    let(:cfj_on_2) { force_create(:custom_field_join, supporter: old_supporter2, custom_field_master: custom_field_master2, value: "cfj_on_2") }
    let(:cfj_on_3) { force_create(:custom_field_join, supporter: old_supporter1, custom_field_master: custom_field_master3, value: "old_cfj", created_at: Time.now - 1.day) }
    let(:cfj_on_4) { force_create(:custom_field_join, supporter: old_supporter2, custom_field_master: custom_field_master3, value: "new_cfj", created_at: Time.now + 1.day) }

    let(:profile) { force_create(:profile) }

    before(:each) do
      np
      old_supporter1
      old_supporter2
      new_supporter
      supporter_note
      card
    end

    it "merges everything properly with tags and cfjs on both" do
      tag_on_1
      tag_on_2
      tag_on_both
      cfj_on_1
      cfj_on_2
      cfj_on_3
      cfj_on_4
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 3
      expect(new_supporter.tag_joins.map { |i| i.tag_master }).to contain_exactly(tag_master, tag_master2, tag_master3)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 3
      expect(new_supporter.custom_field_joins.map { |i| i.custom_field_master }).to contain_exactly(custom_field_master, custom_field_master2, custom_field_master3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master }.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master2 }.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master3 }.value).to eq cfj_on_4.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on first" do
      tag_on_1
      cfj_on_1
      cfj_on_3
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map { |i| i.tag_master }).to contain_exactly(tag_master)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map { |i| i.custom_field_master }).to contain_exactly(custom_field_master, custom_field_master3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master }.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master3 }.value).to eq cfj_on_3.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on second" do
      tag_on_2
      cfj_on_2
      cfj_on_4
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map { |i| i.tag_master }).to contain_exactly(tag_master2)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map { |i| i.custom_field_master }).to contain_exactly(custom_field_master2, custom_field_master3)

      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master2 }.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find { |i| i.custom_field_master == custom_field_master3 }.value).to eq cfj_on_4.value
      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it "merges with tags and cfjs on neighter" do
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
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

    it "updates the card information on the supporter" do
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
      expect(new_supporter.reload.cards.first).to eq(card.reload)
    end

    it "updates the supporter information on the card" do
      old_supporters = Supporter.where("supporters.id IN (?)", [old_supporter1.id, old_supporter2.id])
      MergeSupporters.update_associations(old_supporters, new_supporter, np.id, profile.id)
      expect(card.reload.holder).to eq(new_supporter.reload)
    end
  end

  describe ".selected" do
    it "new supporter is anonymous if any of the old supporters are." do
      old_supporter1.anonymous = true
      old_supporter1.save!
      result = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq true
      expect(result[:json][:name]).to eq "Penelope Schultz"
      expect(result[:json][:nonprofit_id]).to eq np.id
    end

    it "new supporter is not anonymous if none of the old supporters are" do
      result = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq false
      expect(result[:json][:name]).to eq "Penelope Schultz"
      expect(result[:json][:nonprofit_id]).to eq np.id
    end

    it "new supporter matches passed in np even if the merged_data says otherwise" do
      result = MergeSupporters.selected({name: "Penelope Schultz", nonprofit_id: 3333333}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq false
      expect(result[:json][:nonprofit_id]).to eq np.id
      expect(result[:json][:name]).to eq "Penelope Schultz"
    end

    context "skip_conflicting_custom_fields flag" do
      context "when true" do
        context "when custom fields are conflicting" do
          it "returns the supporters that could not be merged" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")
            result = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil, true)
            expect(result[:json]).to match_array([old_supporter1.id, old_supporter2.id])
            expect(result[:status]).to eq(:failure)
          end
        end

        context "when custom fields are not conflicting" do
          it "merges" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            result = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil, true)
            expect(result[:json].custom_field_joins.pluck(:value)).to eq(["foo"])
          end
        end
      end

      context "when false" do
        context "when custom fields are conflicting" do
          # This is undesired, but it's the current behavior.
          # We should probably create copies of the conflicting custom fields instead.
          it "merges anyway" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")
            resulting_supporter = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil, false)[:json]
            expect(resulting_supporter.custom_field_joins.pluck(:value)).to eq(["bar"])
          end
        end

        context "when custom fields are not conflicting" do
          it "merges" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            result = MergeSupporters.selected({name: "Penelope Schultz"}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil, false)
            expect(result[:json].custom_field_joins.pluck(:value)).to eq(["foo"])
          end
        end
      end
    end
  end

  describe ".conflicting_custom_fields?" do
    context "when some custom fields are conflicting" do
      it "returns true" do
        custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
        old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
        old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")
        old_supporter3.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")
        expect(MergeSupporters.conflicting_custom_fields?([old_supporter1, old_supporter2, old_supporter3])).to be_truthy
      end
    end

    context "when no custom fields are conflicting" do
      it "returns false" do
        custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
        old_supporter1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
        old_supporter2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
        old_supporter3.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
        expect(MergeSupporters.conflicting_custom_fields?([old_supporter1, old_supporter2, old_supporter3])).to be_falsy
      end
    end
  end

  describe ".merge_by_id_groups" do
    let(:supporter_1) { np.supporters.create!(name: "Penelope Schultz") }
    let(:supporter_2) { np.supporters.create!(name: "Cacau Borges") }
    let(:result) { MergeSupporters.merge_by_id_groups(np.id, [[supporter_1.id, supporter_2.id]], nil) }

    it "merges the supporters from the id groups" do
      expect(result).to eq([])
      expect(supporter_1.reload.deleted).to be_truthy
      expect(supporter_2.reload.deleted).to be_truthy
      expect(supporter_1.reload.merged_into).not_to be_nil
      expect(supporter_2.reload.merged_into).not_to be_nil
      expect(supporter_1.reload.merged_into).to eq(supporter_2.merged_into)
    end

    it "creates a supporter.created object event" do
      expect { result }.to change { ObjectEvent.where(event_type: "supporter.created").count }.by 1
    end

    context "when the supporters have custom fields" do
      context "when custom fields are conflicting" do
        context "when the skip_conflicting_custom_fields flag is true" do
          it "returns the supporters that could not be merged" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            supporter_1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            supporter_2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")

            result = MergeSupporters.merge_by_id_groups(np.id, [[supporter_1.id, supporter_2.id]], nil, true)
            expect(result).to match_array([[supporter_1.id, supporter_2.id]])
            expect(supporter_1.reload.deleted).to be_falsy
            expect(supporter_2.reload.deleted).to be_falsy
            expect(supporter_1.reload.merged_into).to be_nil
            expect(supporter_2.reload.merged_into).to be_nil
          end
        end

        context "when the skip_conflicting_custom_fields flag is false" do
          it "merges and resturns an empty array" do
            custom_field_master = np.custom_field_masters.create!(name: "A Custom Field")
            supporter_1.custom_field_joins.create!(custom_field_master: custom_field_master, value: "foo")
            supporter_2.custom_field_joins.create!(custom_field_master: custom_field_master, value: "bar")

            expect(result).to eq([])
            expect(supporter_1.reload.deleted).to be_truthy
            expect(supporter_2.reload.deleted).to be_truthy
            expect(supporter_1.reload.merged_into).not_to be_nil
            expect(supporter_2.reload.merged_into).not_to be_nil
            expect(supporter_1.reload.merged_into).to eq(supporter_2.merged_into)
          end
        end
      end
    end
  end
end
