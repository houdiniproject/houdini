# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe CopyNamingAlgorithm do
  describe ".create_copy_name" do
    let(:base_name_short) { "b" }
    let(:base_name_short_copy) { "b_copy-00" }
    let(:base_name_short_copy_1) { "b_copy-01" }
    let(:base_name_short_copy_2) { "b_copy-02" }

    let(:base_name_long) { "ten digits" }
    let(:base_name_long_copy) { "te_copy-00" }
    let(:base_name_long_copy_1) { "te_copy-01" }
    let(:base_name_long_copy_2) { "te_copy-02" }

    it "create copy when none exist already" do
      names = [base_name_short]
      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short)
      expect(result).to eq base_name_short_copy
    end

    it "create copy when one exists already" do
      names = [base_name_short, base_name_short_copy]
      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short)
      expect(result).to eq base_name_short_copy_1

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short_copy)
      expect(result).to eq base_name_short_copy_1
    end

    it "create copy when two exist already" do
      names = [base_name_short, base_name_short_copy, base_name_short_copy_1]

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short)
      expect(result).to eq base_name_short_copy_2

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short_copy)
      expect(result).to eq base_name_short_copy_2

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_short_copy_1)
      expect(result).to eq base_name_short_copy_2
    end

    it "create copy when none exists - longer" do
      names = [base_name_long]
      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long)
      expect(result).to eq base_name_long_copy
    end

    it "create copy when one exists - longer" do
      names = [base_name_long, base_name_long_copy]
      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long)
      expect(result).to eq base_name_long_copy_1

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long_copy)
      expect(result).to eq base_name_long_copy_1
    end

    it "create copy when two exists - longer" do
      names = [base_name_long, base_name_long_copy, base_name_long_copy_1]
      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long)
      expect(result).to eq base_name_long_copy_2

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long_copy)
      expect(result).to eq base_name_long_copy_2

      result = TestCopyNamingAlgorithm.new(name_entities: names).create_copy_name(base_name_long_copy_1)
      expect(result).to eq base_name_long_copy_2
    end

    it "raises ArgumentError on length limit problem" do
      names = ["c"]
      expect { TestCopyNamingAlgorithm.new(name_entities: names, max_length: 4).create_copy_name(names[0]) }.to(raise_error do |e|
        expect(e).to be_a ArgumentError
        expect(e.message).to start_with("It's not possible to generate a name using name_to_copy:")
      end)
    end

    it "raises ArgumentError on copy limit problem" do
      names = ["c", "c_copy-0"]
      expect { TestCopyNamingAlgorithm.new(name_entities: names, max_copies: 1).create_copy_name(names[0]) }.to(raise_error do |e|
        expect(e).to be_a ArgumentError
        expect(e.message).to start_with("It's not possible to generate a UNIQUE name using name_to_copy:")
      end)
    end
  end

  describe ".generate_copy_number" do
    it "adds one digit for copy number if under 10" do
      algo = TestCopyNamingAlgorithm.new(max_copies: 9)
      (0..9).each do |i|
        expect(algo.generate_copy_number(i)).to eq i.to_s
      end
    end
    it "adds 2 digits for copy number if under 100" do
      algo = TestCopyNamingAlgorithm.new(max_copies: 99)
      (0..99).each do |i|
        if i < 10
          expect(algo.generate_copy_number(i)).to eq "0#{i}"
        else
          expect(algo.generate_copy_number(i)).to eq i.to_s
        end
      end
    end

    it "adds 3 digits for copy number if under 1000" do
      algo = TestCopyNamingAlgorithm.new(max_copies: 999)
      (0..999).each do |i|
        if i < 10
          expect(algo.generate_copy_number(i)).to eq "00#{i}"
        elsif i >= 10 && i < 100
          expect(algo.generate_copy_number(i)).to eq "0#{i}"
        else
          expect(algo.generate_copy_number(i)).to eq i.to_s
        end
      end
    end
  end

  class TestCopyNamingAlgorithm < CopyNamingAlgorithm
    attr_accessor :name_entities, :max_copies, :max_length

    def initialize(name_entities: [], max_length: 10, max_copies: 20)
      @name_entities = name_entities
      @max_copies = max_copies
      @max_length = max_length
    end

    def copy_addition
      "_copy"
    end

    def separator_before_copy_number
      "-"
    end

    attr_reader :max_length

    def get_already_used_name_entities(_base_name)
      @name_entities
    end

    attr_reader :max_copies
  end
end
