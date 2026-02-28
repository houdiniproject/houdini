# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe RetrieveActiveRecordItems do
  describe ".retrieve" do
    let(:item) { force_create(:supporter, nonprofit: item2) }
    let(:item2) { force_create(:nm_justice) }

    it "raises if not a class for key" do
      expect { RetrieveActiveRecordItems.retrieve("item" => 1) }.to raise_error(ArgumentError)
    end
    it "raises if optional is false and value is nil" do
      expect { RetrieveActiveRecordItems.retrieve(ActiveRecord => nil) }.to raise_error(ArgumentError)
    end

    it "raises if optional is true and value is not integer" do
      expect { RetrieveActiveRecordItems.retrieve({ActiveRecord => "number"}, true) }.to raise_error(ArgumentError)
    end

    it "raises if optional is true and value is not positive integer" do
      expect { RetrieveActiveRecordItems.retrieve({ActiveRecord => -1}, true) }.to raise_error(ArgumentError)
    end

    it "gets valid item as optional or not" do
      expected = {Supporter => item, Nonprofit => item2}
      expect(RetrieveActiveRecordItems.retrieve(Supporter => item.id, Nonprofit => item2.id)).to eq expected
      expect(RetrieveActiveRecordItems.retrieve({Supporter => item.id, Nonprofit => item2.id}, true)).to eq expected
    end

    it "raises if youve put in an invalid id" do
      expect { RetrieveActiveRecordItems.retrieve(Supporter => 5555, Nonprofit => item2.id) }.to raise_error(ParamValidation::ValidationError)
      expect { RetrieveActiveRecordItems.retrieve({Supporter => 5555, Nonprofit => item2.id}, true) }.to raise_error(ParamValidation::ValidationError)
    end

    it "gets valid item as optional or not" do
      expected = {Supporter => item, User => nil}
      expect(RetrieveActiveRecordItems.retrieve({Supporter => item.id, User => nil}, true)).to eq expected
    end
  end

  describe ".retrieve_from_keys" do
    let(:item) { force_create(:supporter, nonprofit: item2) }
    let(:item2) { force_create(:nm_justice) }

    it "raises if not a class for key" do
      expect { RetrieveActiveRecordItems.retrieve_from_keys({}, "item" => 1) }.to raise_error(ArgumentError)
    end
    it "raises if optional is false and value is nil" do
      expect { RetrieveActiveRecordItems.retrieve_from_keys({data: nil}, Nonprofit => :data) }.to raise_error(ParamValidation::ValidationError)
    end

    it "raises if optional is true and value is not integer" do
      expect { RetrieveActiveRecordItems.retrieve_from_keys({data: ""}, {Nonprofit => :data}, true) }.to raise_error(ParamValidation::ValidationError)
    end

    it "raises if optional is true and value is not positive integer" do
      expect { RetrieveActiveRecordItems.retrieve_from_keys({data: -1}, {Nonprofit => :data}, true) }.to raise_error(ParamValidation::ValidationError)
    end

    it "gets valid item as optional or not" do
      expected = {supporter: item, nonprofit: item2}
      expect(RetrieveActiveRecordItems.retrieve_from_keys({supporter: item.id, nonprofit: item2.id}, Supporter => :supporter, Nonprofit => :nonprofit)).to eq expected
      expect(RetrieveActiveRecordItems.retrieve_from_keys({supporter: item.id, nonprofit: item2.id}, {Supporter => :supporter, Nonprofit => :nonprofit}, true)).to eq expected
    end

    it "raises if youve put in an invalid id" do
      expect { RetrieveActiveRecordItems.retrieve_from_keys({supporter: 5555, nonprofit: item2.id}, Supporter => :supporter, Nonprofit => :nonprofit) }.to raise_error(ParamValidation::ValidationError)
      expect { RetrieveActiveRecordItems.retrieve_from_keys({supporter: 5555, nonprofit: item2.id}, {Supporter => :supporter, Nonprofit => :nonprofit}, true) }.to raise_error(ParamValidation::ValidationError)
    end

    it "gets valid item as optional or not" do
      expected = {supporter: item, user: nil}
      expect(RetrieveActiveRecordItems.retrieve_from_keys({supporter: item.id, user: nil}, {Supporter => :supporter, User => :user}, true)).to eq expected
    end
  end
end
