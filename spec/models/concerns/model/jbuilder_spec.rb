# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Model::Jbuilder do
  describe Model::Jbuilder::BuilderExpansion do
    let(:model) do
      stub_const("HasToBuilderAndToId", Struct.new(:to_id, :to_builder))

      stub_const("ModelClass", Struct.new(:filled, :unfilled, :enumerable, :json_based_id, :flat_enumerable))

      ModelClass.new(
        HasToBuilderAndToId.new("id_result", "builder_result"),
        nil,
        [
          HasToBuilderAndToId.new("enumerable_id_result_1", Jbuilder.new { |json| json.id "enumerable_builder_result_1" }),
          HasToBuilderAndToId.new("enumerable_id_result_2", Jbuilder.new { |json| json.id "enumerable_builder_result_2" })
        ],
        HasToBuilderAndToId.new(Jbuilder.new do |json|
          json.id "json_based_id"
        end, "expanded"),
        %w[
          flat_id_result_1
          flat_id_result_2
        ]
      )
    end
    let(:filled_expansion) { described_class.new(key: :filled, json_attribute: "filled_attrib") }
    let(:unfilled_expansion) { described_class.new(key: :unfilled) }
    let(:nonexistent_expansion) { described_class.new(key: :nonexistent) }
    let(:expandable_expansion) { described_class.new(key: :enumerable, enum_type: :expandable) }
    let(:flat_expansion) { described_class.new(key: :flat_enumerable, enum_type: :flat) }

    describe "expansion where the attribute is filled" do
      subject { filled_expansion }

      it {
        is_expected.to have_attributes(
          json_attribute: "filled_attrib",
          enumerable?: false,
          flat_enum?: false,
          expandable_enum?: false
        )
      }

      describe "#to_id" do
        subject { filled_expansion.to_id.call(model) }

        it { is_expected.to eq "id_result" }
      end

      describe "#to_builder" do
        subject { filled_expansion.to_builder.call(model) }

        it { is_expected.to eq "builder_result" }
      end
    end

    describe "expansion where the attribute is unfilled" do
      subject { unfilled_expansion }

      it {
        is_expected.to have_attributes(
          json_attribute: "unfilled",
          enumerable?: false,
          flat_enum?: false,
          expandable_enum?: false
        )
      }

      describe "#to_id" do
        subject { unfilled_expansion.to_id.call(model) }

        it { is_expected.to be_nil }
      end

      describe "#to_builder" do
        subject { unfilled_expansion.to_builder.call(model) }

        it { is_expected.to be_nil }
      end
    end

    describe "expansion where the attribute is nonexistent" do
      subject { nonexistent_expansion }

      it {
        is_expected.to have_attributes(
          json_attribute: "nonexistent",
          enumerable?: false,
          flat_enum?: false,
          expandable_enum?: false
        )
      }

      it ".to_id raises error" do
        expect { nonexistent_expansion.to_id.call(model) }.to raise_error ActiveModel::MissingAttributeError
      end

      it ".to_builder raises error" do
        expect { nonexistent_expansion.to_builder.call(model) }.to raise_error ActiveModel::MissingAttributeError
      end
    end

    describe "expansion of expandable enumerable returns an enumerable" do
      subject { expandable_expansion }

      it {
        is_expected.to have_attributes(
          json_attribute: "enumerable",
          enumerable?: true,
          flat_enum?: false,
          expandable_enum?: true
        )
      }

      describe "#to_id" do
        subject { expandable_expansion.to_id.call(model) }

        it { is_expected.to match(%w[enumerable_id_result_1 enumerable_id_result_2]) }
      end

      describe "#to_builder" do
        subject { expandable_expansion.to_builder.call(model) }

        it { is_expected.to match([{"id" => "enumerable_builder_result_1"}, {"id" => "enumerable_builder_result_2"}]) }
      end
    end

    describe "expansion of flat enumerable returns an enumerable" do
      subject { flat_expansion }

      it {
        is_expected.to have_attributes(
          json_attribute: "flat_enumerable",
          enumerable?: true,
          flat_enum?: true,
          expandable_enum?: false
        )
      }

      describe "#to_id" do
        subject { flat_expansion.to_id.call(model) }

        it { is_expected.to match(%w[flat_id_result_1 flat_id_result_2]) }
      end

      describe "#to_builder" do
        subject { flat_expansion.to_builder.call(model) }

        it { is_expected.to match(%w[flat_id_result_1 flat_id_result_2]) }
      end
    end
  end
end
