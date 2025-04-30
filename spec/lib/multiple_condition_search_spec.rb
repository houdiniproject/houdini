# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe MultipleConditionSearch do
  describe ".find" do
    let!(:parent) { create(:simple_object) }
    let!(:child_obj_1) { create(:simple_object, parent: parent) }
    let!(:child_obj_2) { create(:simple_object, parent: parent) }
    context "on the first condition" do
      context "no record is found" do
        let(:search_obj) { MultipleConditionSearch.new([{houid: "some fake houid"}]) }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return nil" do
          expect(result).to be_nil
        end

        it "will have a result of nil" do
          expect(search_obj.result).to be_nil
        end

        it "will have an error of none" do
          expect(search_obj.error).to eq :none
        end
      end

      context "the correct record is found" do
        let(:search_obj) { MultipleConditionSearch.new([{houid: parent.houid}]) }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return parent" do
          expect(result).to eq parent
        end

        it "will have a result of parent" do
          expect(search_obj.result).to eq parent
        end

        it "will have an error of nil" do
          expect(search_obj.error).to be_nil
        end
      end

      context "multiple records are found" do
        let(:search_obj) { MultipleConditionSearch.new([["parent_id = ?", parent.id]]) }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return nil" do
          expect(result).to eq nil
        end

        it "will have a result of  two child objects" do
          expect(search_obj.result).to match_array([child_obj_1, child_obj_2])
        end

        it "will have an error of multiple_values" do
          expect(search_obj.error).to eq :multiple_values
        end
      end
    end

    context "on multiple conditions" do
      context "no record is found" do
        let(:search_obj) {
          MultipleConditionSearch.new([
            ["houid = ?", "some fake houid"],
            ["houid = ? or houid = 'another fake houid'", "some_fake_houid"]
          ])
        }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return nil" do
          expect(result).to be_nil
        end

        it "will have a result of nil" do
          expect(search_obj.result).to be_nil
        end

        it "will have an error of none" do
          expect(search_obj.error).to eq :none
        end
      end

      context "the correct record is found" do
        let(:search_obj) {
          MultipleConditionSearch.new([
            {parent_id: parent.id},
            ["parent_id = ? AND houid = ?", parent.id, child_obj_2.houid]
          ])
        }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return child_obj_2" do
          expect(result).to eq child_obj_2
        end

        it "will have a result of child_obj_2" do
          expect(search_obj.result).to eq child_obj_2
        end

        it "will have an error of nil" do
          expect(search_obj.error).to be_nil
        end
      end

      context "multiple records are found" do
        let(:search_obj) {
          MultipleConditionSearch.new([
            "parent_id = #{parent.id}",
            ["parent_id = ? AND (houid = ? OR houid = ?)", parent.id, child_obj_1.houid, child_obj_2.houid]
          ])
        }
        let!(:result) { search_obj.find(SimpleObject.all) }

        it "will return nil" do
          expect(result).to be_nil
        end

        it "will have a result of child_obj_2" do
          expect(search_obj.result).to match_array([child_obj_1, child_obj_2])
        end

        it "will have an error of nil" do
          expect(search_obj.error).to eq :multiple_values
        end
      end
    end

    context "does not crash with quotes" do
      let(:search_obj) {
        fake_houid = "O'Leary"
        MultipleConditionSearch.new([
          houid: fake_houid
        ])
      }

      it "doesnt raise an error" do
        expect { search_obj.find(SimpleObject.all) }.to_not raise_error
      end
    end
  end
end
