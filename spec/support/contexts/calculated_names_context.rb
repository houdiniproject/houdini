# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
# rubocop:disable RSpec/VerifiedDoubles, RSpec/MessageSpies regular doubles work fine in this use-case

RSpec.shared_examples "a model with a calculated first and last name" do
  let(:instance) { subject }

  describe "#calculated_first_name" do
    it "has nil name" do
      instance.name = nil
      expect(instance.calculated_first_name).to be_nil
    end

    it "has blank name" do
      instance.name = ""
      expect(instance.calculated_first_name).to be_nil
    end

    it "has one word name" do
      instance.name = "Penelope"
      expect(instance.calculated_first_name).to eq "Penelope"
    end

    it "has two word name" do
      instance.name = "Penelope Schultz"
      expect(instance.calculated_first_name).to eq "Penelope"
    end

    it "has three word name" do
      instance.name = "Penelope Rebecca Schultz"
      expect(instance.calculated_first_name).to eq "Penelope Rebecca"
    end
  end

  describe "#calculated_last_name" do
    it "has nil name" do
      instance.name = nil
      expect(instance.calculated_last_name).to be_nil
    end

    it "has blank name" do
      instance.name = ""
      expect(instance.calculated_last_name).to be_nil
    end

    it "has one word name" do
      instance.name = "Penelope"
      expect(instance.calculated_last_name).to be_nil
    end

    it "has two word name" do
      instance.name = "Penelope Schultz"
      expect(instance.calculated_last_name).to eq "Schultz"
    end

    it "has three word name" do
      instance.name = "Penelope Rebecca Schultz"
      expect(instance.calculated_last_name).to eq "Schultz"
    end
  end
end
