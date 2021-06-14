require "rails_helper"

describe MergeSupporters do

  let(:np) {force_create(:nonprofit)}
  let(:old_supporter1) { force_create(:supporter, nonprofit: np) }
  let(:old_supporter2) { force_create(:supporter, nonprofit: np) }
  let(:card) { force_create(:card, holder: old_supporter1) }
  around(:each) do |e|
    Timecop.freeze(2020, 3, 4) do
      e.run
    end
  end
  
  describe '.update_associations' do
    #one unique tag for 1
    # one unique tag for 2
    # one common tag on both
    #
    # one unique custom field on 1
    # one unique custom field on 2
    # one common field on both and keep the value of the most common

    let(:new_supporter) {force_create(:supporter, nonprofit:np)}

    let(:supporter_note) {force_create(:supporter_note, supporter: old_supporter1, content: "feoatheoiath")}

    let(:tag_master) {force_create(:tag_master, nonprofit: np, name: 'something')}
    let(:tag_master2) {force_create(:tag_master, nonprofit: np, name: 'something2')}
    let(:tag_master3) {force_create(:tag_master, nonprofit: np, name: 'something3')}

    let(:tag_on_1) {force_create(:tag_join, tag_master: tag_master, supporter_id: old_supporter1.id)}
    let(:tag_on_2) {force_create(:tag_join, tag_master: tag_master2, supporter_id: old_supporter2.id)}
    let(:tag_on_both) {[old_supporter1, old_supporter2].each{|i| force_create(:tag_join, tag_master:tag_master3, supporter_id:i.id)}}

    let(:custom_field_master) {force_create(:custom_field_master, nonprofit: np, name: 'cfm1')}
    let(:custom_field_master2) {force_create(:custom_field_master, nonprofit: np, name: 'cfm2')}
    let(:custom_field_master3) {force_create(:custom_field_master, nonprofit: np, name: 'cfm3')}

    let(:cfj_on_1) { force_create(:custom_field_join, supporter:old_supporter1, custom_field_master: custom_field_master, value: 'cfj_on_1')}
    let(:cfj_on_2) { force_create(:custom_field_join, supporter:old_supporter2, custom_field_master: custom_field_master2, value: 'cfj_on_2')}
    let(:cfj_on_3) {force_create(:custom_field_join, supporter:old_supporter1, custom_field_master: custom_field_master3, value: 'old_cfj', created_at: Time.now - 1.day)}
    let(:cfj_on_4) {force_create(:custom_field_join, supporter:old_supporter2, custom_field_master: custom_field_master3, value: 'new_cfj', created_at: Time.now + 1.day)}

    let(:profile) {force_create(:profile)}

    before(:each) do
      np
      old_supporter1
      old_supporter2
      new_supporter
      supporter_note
      card
    end

    it 'merges everything properly with tags and cfjs on both' do
      tag_on_1
      tag_on_2
      tag_on_both
      cfj_on_1
      cfj_on_2
      cfj_on_3
      cfj_on_4
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 3
      expect(new_supporter.tag_joins.map{|i| i.tag_master}).to contain_exactly(tag_master, tag_master2, tag_master3)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 3
      expect(new_supporter.custom_field_joins.map{|i| i.custom_field_master}).to contain_exactly(custom_field_master, custom_field_master2, custom_field_master3)

      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master}.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master2}.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master3}.value).to eq cfj_on_4.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it 'merges with tags and cfjs on first' do
      tag_on_1
      cfj_on_1
      cfj_on_3
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map{|i| i.tag_master}).to contain_exactly(tag_master)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map{|i| i.custom_field_master}).to contain_exactly(custom_field_master, custom_field_master3)

      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master}.value).to eq cfj_on_1.value
      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master3}.value).to eq cfj_on_3.value

      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it 'merges with tags and cfjs on second' do
      tag_on_2
      cfj_on_2
      cfj_on_4
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
      old_supporter1.reload
      old_supporter2.reload
      expect(old_supporter1.tag_joins.count).to eq 0
      expect(old_supporter2.tag_joins.count).to eq 0
      expect(new_supporter.tag_joins.count).to eq 1
      expect(new_supporter.tag_joins.map{|i| i.tag_master}).to contain_exactly(tag_master2)

      expect(old_supporter1.custom_field_joins.count).to eq 0
      expect(old_supporter2.custom_field_joins.count).to eq 0
      expect(new_supporter.custom_field_joins.count).to eq 2
      expect(new_supporter.custom_field_joins.map{|i| i.custom_field_master}).to contain_exactly(custom_field_master2, custom_field_master3)

      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master2}.value).to eq cfj_on_2.value
      expect(new_supporter.custom_field_joins.find{|i| i.custom_field_master == custom_field_master3}.value).to eq cfj_on_4.value
      expect(new_supporter.supporter_notes.first.id).to eq supporter_note.id
    end

    it 'merges with tags and cfjs on neighter' do
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
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

    it 'updates the card information on the supporter' do
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
      expect(new_supporter.reload.cards.first).to eq(card.reload)
    end

    it 'updates the supporter information on the card' do
      MergeSupporters.update_associations([old_supporter1.id, old_supporter2.id], new_supporter, np.id, profile.id)
      expect(card.reload.holder).to eq(new_supporter.reload)
    end
  end

  describe '.selected' do

    it 'new supporter is anonymous if any of the old supporters are.' do
      old_supporter1.anonymous = true
      old_supporter1.save!
      result = MergeSupporters.selected({name: 'Penelope Schultz'}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq true
      expect(result[:json][:name]).to eq 'Penelope Schultz'
      expect(result[:json][:nonprofit_id]).to eq np.id
    end

    it 'new supporter is not anonymous if none of the old supporters are' do
      result = MergeSupporters.selected({name: 'Penelope Schultz'}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq false
      expect(result[:json][:name]).to eq 'Penelope Schultz'
      expect(result[:json][:nonprofit_id]).to eq np.id
    end

    it 'new supporter matches passed in np even if the merged_data says otherwise' do
      result = MergeSupporters.selected({name: 'Penelope Schultz', nonprofit_id: 3333333}.with_indifferent_access, [old_supporter1.id, old_supporter2.id], np.id, nil)
      expect(result[:json][:anonymous]).to eq false
      expect(result[:json][:nonprofit_id]).to eq np.id
      expect(result[:json][:name]).to eq 'Penelope Schultz'
    end
  end
end