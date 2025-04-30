RSpec.shared_examples "a model which can validate international fees" do |local_fee_model, countryless_fee_model|
  describe "#charge_international_fee?" do
    context "when source is in same country" do
      subject { create(:us_local_fee_structure) }
      it { is_expected.to_not be_charge_international_fee(source_from_us) }
    end

    context "when source is in different country" do
      subject { create(:us_local_fee_structure) }
      it { is_expected.to be_charge_international_fee(source_from_uk) }
    end

    context "when fee structure has no local country" do
      subject { create(:countryless_fee_structure) }
      it { is_expected.to_not be_charge_international_fee(source_from_uk) }
    end
  end
end
