# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "InsertTagJoins.in_bulk" do
  context "parameter validation" do
    it "should validate parameters" do
      response = InsertTagJoins.in_bulk(nil, nil, "no", nil)
      errors = response[:json][:errors]
      expect(errors.length).to eq(6)
      expect(response[:status]).to eq(:unprocessable_entity)
      expect_validation_errors(errors, [
        {key: :np_id, name: :required},
        {key: :np_id, name: :is_integer},
        {key: :profile_id, name: :required},
        {key: :profile_id, name: :is_integer},
        {key: :supporter_ids, name: :is_array},
        {key: :tag_data, name: :required}
      ])
    end
    context "requiring db" do
      before {
        @nonprofit = force_create(:nonprofit)
        @profile = force_create(:profile)
      }

      it "nonprofit must be valid" do
        response = InsertTagJoins.in_bulk(@nonprofit.id + 1, @profile.id, [1], [])
        expect(response[:status]).to eq(:unprocessable_entity)
        expect(response[:json][:error]).to include("Nonprofit #{@nonprofit.id + 1} is not valid")
      end

      it "profile must be valid" do
        response = InsertTagJoins.in_bulk(@nonprofit.id, @profile.id + 1, [1], [])
        expect(response[:status]).to eq(:unprocessable_entity)
        expect(response[:json][:error]).to include("Profile #{@profile.id + 1} is not valid")
      end

      it "supporters if empty should do nothing" do
        response = InsertTagJoins.in_bulk(@nonprofit.id, @profile.id, [], [])
        expect(response).to eq(successful_json(0, 0))
      end
    end
  end

  context "supporters tags" do
    before(:each) {
      @nonprofit = force_create(:nonprofit)
      @profile = force_create(:profile)

      @random_supporter = create(:supporter)

      @other_nonprofit = force_create(:nonprofit)
      @delete_tags = [20, 40, 60]
      @add_tags = [25, 35]

      @supporters = {
        np_supporter_with_add: {
          creation_hash: {nonprofit: @nonprofit},
          tag_ids: [65, 75, 85]
        },
        np_supporter_with_tags_to_delete: {
          creation_hash: {nonprofit: @nonprofit},
          tag_ids: [40, 75, 85]
        },

        np_supporter_with_no_changes: {
          creation_hash: {nonprofit: @nonprofit},
          tag_ids: @add_tags
        },
        np_supporter_with_some_of_both: {
          creation_hash: {nonprofit: @nonprofit},
          tag_ids: [20, 35]
        },
        supporter_from_other_np: {
          creation_hash: {nonprofit: @other_nonprofit},
          tag_ids: [100, 150, 200]
        }

      }

      @supporters = {
        np_supporter_with_add: {
          tag_ids: [65, 75, 85]
        },
        np_supporter_with_tags_to_delete: {
          tag_ids: [40, 75, 85]
        },

        np_supporter_with_no_changes: {
          tag_ids: @add_tags
        },
        np_supporter_with_some_of_both: {

          tag_ids: [20, 35]
        },
        supporter_from_other_np: {
          tag_ids: [100, 150, 200],
          other_np: true
        }

      }

      @supporters.each_key { |k|
        i = @supporters[k]
        nonprofit_for_supporter = i[:other_np] ? @other_nonprofit : @nonprofit
        i[:entity] = create(:supporter, nonprofit: nonprofit_for_supporter)
        i[:tag_ids].each { |j|
          tm = TagMaster.exists?(id: j) ? TagMaster.find(j) : create(:tag_master, id: j, nonprofit: nonprofit_for_supporter, name: "TM #{j}")
          create(:tag_join, supporter_id: i[:entity].id, tag_master: tm)
        }
      }
    }

    it "invalid nonprofit-supporter combo returns okay" do
      results = InsertTagJoins.in_bulk(@nonprofit.id, @profile.id, [@supporters[:supporter_from_other_np][:entity].id], {})
      expect(results).to eq(successful_json(0, 0))
    end

    it "strips tags which dont belong to nonprofit" do
      results = InsertTagJoins.in_bulk(@nonprofit.id, @profile.id, [@supporters[:np_supporter_with_add][:entity].id],
        create_tag_data([100], [150]))
      expect(results).to eq(successful_json(0, 0))

      expect(TagJoin.where("supporter_id = ? and tag_master_id = ?", @supporters[:np_supporter_with_add][:entity].id, 100).count).to eq 0
    end

    it "delete" do
      expect(TagJoin.count).to eq 13
      @supporters[:np_supporter_with_some_of_both][:entity].id

      InsertTagJoins.in_bulk(@nonprofit.id, @profile.id,
        [@supporters[:np_supporter_with_some_of_both][:entity].id, @supporters[:np_supporter_with_tags_to_delete][:entity].id, @supporters[:np_supporter_with_add][:entity].id, @supporters[:supporter_from_other_np][:entity].id, @supporters[:np_supporter_with_no_changes][:entity].id],
        create_tag_data(@add_tags, @delete_tags))

      expect(TagJoin.where("supporter_id = ? ", @supporters[:np_supporter_with_some_of_both][:entity].id).count).to eq 2

      expect(TagJoin.where("supporter_id = ?", @supporters[:np_supporter_with_add][:entity].id).count).to eq 5

      expect(TagJoin.where("supporter_id = ?", @supporters[:np_supporter_with_tags_to_delete][:entity].id).count).to eq 4

      expect(TagJoin.where("supporter_id = ?", @supporters[:supporter_from_other_np][:entity].id).count).to eq 3

      expect(TagJoin.where("supporter_id = ?", @supporters[:np_supporter_with_no_changes][:entity].id).count).to eq 2

      expect(TagJoin.count).to eq 16
    end

    it "add_to_one" do
      expect(TagJoin.count).to eq 13

      np_supporter_with_add_tags = @supporters[:np_supporter_with_add][:entity].tag_joins.to_a
      np_supporter_with_some_of_both_tags = @supporters[:np_supporter_with_some_of_both][:entity].tag_joins.to_a
      np_supporter_with_no_changes_tags = @supporters[:np_supporter_with_no_changes][:entity].tag_joins.to_a

      Timecop.travel(20) {
        results = InsertTagJoins.in_bulk(@nonprofit.id, @profile.id,
          [
            @supporters[:np_supporter_with_add][:entity].id, # add 2
            @supporters[:np_supporter_with_no_changes][:entity], # update 2
            @supporters[:np_supporter_with_some_of_both][:entity].id
          ], # add 2, delete 1
          create_tag_data(@add_tags, @delete_tags))

        expect(results).to eq(successful_json(6, 1))

        expect(@supporters[:np_supporter_with_no_changes][:entity].tag_joins).to match_array(np_supporter_with_no_changes_tags)

        expect(TagJoin.where("supporter_id = ? ", @supporters[:np_supporter_with_add][:entity].id).count).to eq 5

        original_db_pairs = get_original_and_db(np_supporter_with_add_tags, TagJoin.where("supporter_id = ? and tag_master_id in (?)",
          @supporters[:np_supporter_with_add][:entity].id,
          @supporters[:np_supporter_with_add][:tag_ids]).pluck(:id))

        original_db_pairs.each { |orig, db|
          expect(orig.attributes.length).to eq(db.attributes.length)
          expect(orig.attributes).to eq(db.attributes)
        }

        expect(TagJoin.where("supporter_id = ?", @supporters[:np_supporter_with_some_of_both][:entity].id).count).to eq 2

        original_db_pairs = get_original_and_db(np_supporter_with_some_of_both_tags, TagJoin.where("supporter_id = ? and tag_master_id in (?)",
          @supporters[:np_supporter_with_some_of_both][:entity].id,
          [35]).pluck(:id))
        original_db_pairs.each { |orig, db|
          expect(orig.attributes.length).to eq(db.attributes.length)
          expect(orig.attributes.select { |key, value| key != "updated_at" }).to eq(db.attributes.select { |key, value| key != "updated_at" })
          expect(orig.attributes["updated_at"]).to be < db.attributes["updated_at"]
        }

        expect(TagJoin.count).to eq 15
      }
    end
  end

  def get_original_and_db(original_items, ids_to_verify)
    ids_to_verify.map { |i|
      original_item = original_items.find { |oi| oi[:id] == i }
      db_item = TagJoin.find(i)
      [original_item, db_item]
    }
  end

  def successful_json(inserted, deleted)
    {json: {inserted_count: inserted, removed_count: deleted}, status: :ok}
  end

  def create_tag_data(tags_to_add = [], tags_to_delete = [])
    tags_to_add.map { |tag| {tag_master_id: tag, selected: true} } + tags_to_delete.map { |tag| {tag_master_id: tag, selected: false} }
  end
end
