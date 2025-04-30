require "rails_helper"

RSpec.describe FeeCoverageDetailBase, type: :model do
  context "validation" do
    it { is_expected.to belong_to(:fee_era).validate(true) }
  end
end
