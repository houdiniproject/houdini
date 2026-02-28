# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertCustomFieldJoins do
  describe ".find_or_create" do
    let(:nonprofit) { force_create(:nm_justice) }
    let(:other_nonprofit) { force_create(:fv_poverty) }
    let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
    let(:other_supporter) { force_create(:supporter, nonprofit: other_nonprofit) }

    let(:initial_custom_field_definition) { force_create(:custom_field_definition, nonprofit: nonprofit, name: "CFM Name") }

    describe "param validation" do
      it "basic validation" do
        expect { InsertCustomFieldJoins.find_or_create(nil, nil, nil) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :np_id, name: :required},
            {key: :np_id, name: :is_integer},
            {key: :supporter_ids, name: :required},
            {key: :supporter_ids, name: :is_array},
            {key: :supporter_ids, name: :min_length},
            {key: :field_data, name: :required},
            {key: :field_data, name: :is_array},
            {key: :field_data, name: :min_length}
          ])
        end)
      end

      it "validate nonprofit existence" do
        expect { InsertCustomFieldJoins.find_or_create(5, [555], [[1, 1]]) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :np_id}
          ])

          expect(error.message).to eq "5 is not a valid non-profit"
        end)
      end

      it "validate supporter in nonprofit" do
        expect { InsertCustomFieldJoins.find_or_create(nonprofit.id, [other_supporter.id], [[1, 1]]) }.to(raise_error do |error|
          expect(error).to be_a ParamValidation::ValidationError
          expect_validation_errors(error.data, [
            {key: :supporter_ids}
          ])

          expect(error.message).to eq "#{other_supporter.id} is not a valid supporter for nonprofit #{nonprofit.id}"
        end)
      end
    end

    it "run insert" do
      new_cf_name = "new cf name"
      new_cf_value = "value"
      old_cf_value = "old_cf_value"
      expect(InsertCustomFieldJoins).to receive(:in_bulk) do |np_id, supporters_id, field_data|
        expect(np_id).to eq nonprofit.id
        expect(supporters_id).to eq [supporter.id]
        expect(field_data.length).to eq 2
        expect(field_data).to include(custom_field_definition_id: initial_custom_field_definition.id, value: old_cf_value)
        expect(field_data).to include(custom_field_definition_id: CustomFieldDefinition.where(name: new_cf_name).first.id, value: new_cf_value)
      end
      InsertCustomFieldJoins.find_or_create(nonprofit.id, [supporter.id], [
        [
          initial_custom_field_definition.name,
          old_cf_value
        ],
        [
          new_cf_name,
          new_cf_value
        ]
      ])
      expect(CustomFieldDefinition.count).to eq 2
    end
  end

  describe ".in_bulk" do
    context "parameter validation" do
      it "should validate parameters" do
        response = InsertCustomFieldJoins.in_bulk(nil, nil, nil)
        errors = response[:json][:errors]
        expect(errors.length).to eq(6)
        expect(response[:status]).to eq :unprocessable_entity
        expect_validation_errors(errors, [
          {key: :np_id, name: :required},
          {key: :np_id, name: :is_integer},
          {key: :supporter_ids, name: :required},
          {key: :supporter_ids, name: :is_array},
          {key: :field_data, name: :is_array},
          {key: :field_data, name: :required}
        ])
      end
      context "requiring db" do
        before do
          @nonprofit = force_create(:nm_justice)
          @bad_nonprofit = force_create(:fv_poverty, id: 50)
        end

        it "nonprofit must be valid" do
          response = InsertCustomFieldJoins.in_bulk(@nonprofit.id + 1, [], [])
          expect(response[:status]).to eq :unprocessable_entity
          expect(response[:json][:error]).to include("Nonprofit #{@nonprofit.id + 1} is not valid")
        end

        it "supporters if empty should do nothing" do
          response = InsertCustomFieldJoins.in_bulk(@nonprofit.id, [], [])
          expect(response).to eq(successful_json(0, 0))
        end

        it "supporters if empty should do nothing" do
          response = InsertCustomFieldJoins.in_bulk(@nonprofit.id, [50], [])
          expect(response).to eq(successful_json(0, 0))
        end
      end
    end

    context "main testing" do
      before do
        @nonprofit = force_create(:nm_justice)
        @other_nonprofit = force_create(:fv_poverty)
        @random_supporter = create(:supporter, nonprofit: @other_nonprofit)

        @delete_cfm = [20, 40, 60]
        @add_cfm = [25, 35]

        @supporters = {
          np_supporter_with_add: {
            cfm_ids: [65, 75, 85]
          },
          np_supporter_with_cfms_to_delete: {
            cfm_ids: [40, 75, 85]
          },

          np_supporter_with_no_changes: {
            cfm_ids: @add_cfm
          },
          np_supporter_with_some_of_both: {

            cfm_ids: [20, 35]
          },
          supporter_from_other_np: {
            cfm_ids: [100, 150, 200],
            other_np: true
          }

        }

        @supporters.each_key do |k|
          i = @supporters[k]
          nonprofit_for_supporter = i[:other_np] ? @other_nonprofit : @nonprofit
          i[:entity] = create(:supporter, nonprofit: nonprofit_for_supporter)
          i[:cfm_ids].each do |j|
            cfm = CustomFieldDefinition.exists?(id: j) ? CustomFieldDefinition.find(j) : create(:custom_field_definition, id: j, nonprofit: nonprofit_for_supporter, name: "CFM #{j}")

            create(:custom_field_join, :value_from_id, supporter_id: i[:entity].id, custom_field_definition: cfm)
          end
        end
      end

      it "invalid nonprofit-supporter combo returns okay" do
        results = InsertCustomFieldJoins.in_bulk(@nonprofit.id, [@supporters[:supporter_from_other_np][:entity].id], [])
        expect(results).to eq(successful_json(0, 0))
      end

      it "strips cfms which dont belong to nonprofit" do
        results = InsertCustomFieldJoins.in_bulk(@nonprofit.id, [@supporters[:np_supporter_with_add][:entity].id],
          create_cfm_data([100], [150]))
        expect(results).to eq(successful_json(0, 0))

        expect(CustomFieldJoin.where("supporter_id = ? and custom_field_definition_id = ?", @supporters[:np_supporter_with_add][:entity].id, 100).count).to eq 0
      end

      it "delete" do
        expect(CustomFieldJoin.count).to eq 13
        @supporters[:np_supporter_with_some_of_both][:entity].id

        InsertCustomFieldJoins.in_bulk(@nonprofit.id,
          [@supporters[:np_supporter_with_some_of_both][:entity].id, @supporters[:np_supporter_with_cfms_to_delete][:entity].id, @supporters[:np_supporter_with_add][:entity].id, @supporters[:supporter_from_other_np][:entity].id, @supporters[:np_supporter_with_no_changes][:entity].id],
          create_cfm_data(@add_cfm, @delete_cfm))

        expect(CustomFieldJoin.where("supporter_id = ? ", @supporters[:np_supporter_with_some_of_both][:entity].id).count).to eq 2

        expect(CustomFieldJoin.where("supporter_id = ?", @supporters[:np_supporter_with_add][:entity].id).count).to eq 5

        expect(CustomFieldJoin.where("supporter_id = ?", @supporters[:np_supporter_with_cfms_to_delete][:entity].id).count).to eq 4

        expect(CustomFieldJoin.where("supporter_id = ?", @supporters[:supporter_from_other_np][:entity].id).count).to eq 3

        expect(CustomFieldJoin.where("supporter_id = ?", @supporters[:np_supporter_with_no_changes][:entity].id).count).to eq 2

        expect(CustomFieldJoin.count).to eq 16
      end

      it "id, updated_at, created_at changes are stripped" do
        invalid_id = 10_000_000
        Timecop.freeze(2020, 9, 1, 12, 0, 0) do
          results = InsertCustomFieldJoins.in_bulk(@nonprofit.id,
            [@supporters[:np_supporter_with_add][:entity].id],
            [{custom_field_definition_id: 25, value: "CFM value 25", id: invalid_id, created_at: Time.now.ago(3000), updated_at: Time.now.ago(2999)}])
          expected = {custom_field_definition_id: 25, value: "CFM value 25", created_at: Time.now, updated_at: Time.now, supporter_id: @supporters[:np_supporter_with_add][:entity].id}.with_indifferent_access

          expect(results).to eq(successful_json(1, 0))

          result_tag = @supporters[:np_supporter_with_add][:entity].custom_field_joins.where("custom_field_definition_id = ?", 25).first

          expect(result_tag.attributes.with_indifferent_access.reject { |k, _| k == "id" }).to eq(expected)

          expect(result_tag.attributes[:id]).to_not eq invalid_id
        end
      end

      it "add_to_one" do
        expect(CustomFieldJoin.count).to eq 13

        np_supporter_with_add_cfms = @supporters[:np_supporter_with_add][:entity].custom_field_joins.to_a
        np_supporter_with_some_of_both_cfms = @supporters[:np_supporter_with_some_of_both][:entity].custom_field_joins.to_a
        np_supporter_with_no_changes_cfms = @supporters[:np_supporter_with_no_changes][:entity].custom_field_joins.to_a

        Timecop.travel(20) do
          results = InsertCustomFieldJoins.in_bulk(@nonprofit.id,
            [
              @supporters[:np_supporter_with_add][:entity].id, # add 2
              @supporters[:np_supporter_with_no_changes][:entity], # update 2
              @supporters[:np_supporter_with_some_of_both][:entity].id
            ], # add 2, delete 1
            create_cfm_data(@add_cfm, @delete_cfm))

          expect(results).to eq(successful_json(6, 1))

          expect(@supporters[:np_supporter_with_no_changes][:entity].custom_field_joins).to match_array(np_supporter_with_no_changes_cfms)

          expect(CustomFieldJoin.where("supporter_id = ? ", @supporters[:np_supporter_with_add][:entity].id).count).to eq 5

          original_db_pairs = get_original_and_db(np_supporter_with_add_cfms, CustomFieldJoin.where("supporter_id = ? and custom_field_definition_id in (?)",
            @supporters[:np_supporter_with_add][:entity].id,
            @supporters[:np_supporter_with_add][:cfm_ids]).pluck(:id))

          original_db_pairs.each do |orig, db|
            expect(db.attributes.length).to eq(orig.attributes.length)
            expect(db.attributes).to eq(orig.attributes)
          end

          expect(CustomFieldJoin.where("supporter_id = ?", @supporters[:np_supporter_with_some_of_both][:entity].id).count).to eq 2

          original_db_pairs = get_original_and_db(np_supporter_with_some_of_both_cfms, CustomFieldJoin.where("supporter_id = ? and custom_field_definition_id in (?)",
            @supporters[:np_supporter_with_some_of_both][:entity].id,
            [35]).pluck(:id))
          skip_attribs = %w[updated_at value]
          original_db_pairs.each do |orig, db|
            expect(db.attributes.length).to eq(orig.attributes.length)
            expect(db.attributes.reject { |key, _value| skip_attribs.include?(key) }).to eq(orig.attributes.reject { |key, _value| skip_attribs.include?(key) })
            expect(db.attributes["updated_at"]).to be > orig.attributes["updated_at"]
            expect(db.attributes["value"]).to eq "CFM value 35"
          end

          expect(CustomFieldJoin.count).to eq 15
        end
      end
    end
  end

  def successful_json(inserted, deleted)
    {json: {inserted_count: inserted, removed_count: deleted}, status: :ok}
  end

  def create_cfm_data(cfm_to_add = [], cfm_to_delete = [])
    use_nil = true
    cfm_to_add.map { |cfm| {custom_field_definition_id: cfm, value: "CFM value #{cfm}"} } + cfm_to_delete.map do |cfm|
      value = use_nil ? nil : ""
      use_nil = !use_nil
      {custom_field_definition_id: cfm, value: value}
    end
  end

  def get_original_and_db(original_items, ids_to_verify)
    ids_to_verify.map do |i|
      original_item = original_items.find { |oi| oi[:id] == i }
      db_item = CustomFieldJoin.find(i)
      [original_item, db_item]
    end
  end
end
