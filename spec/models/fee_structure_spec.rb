require "rails_helper"

RSpec.shared_examples "a fee structure with calculation arg validation" do
  include_context "Stripe::Source doubles"
  let(:our_fee_structure) { subject }

  describe "#calculate_fee" do
    it {
      expect {
        our_fee_structure.calculate_fee(
          amount: -10,
          source: source_from_us,
          platform_fee: 0
        )
      }.to raise_error(ArgumentError)
    }

    it {
      expect {
        our_fee_structure.calculate_fee(
          amount: 1000,
          source: nil,
          platform_fee: -1
        )
      }.to raise_error(ArgumentError)
    }

    it {
      expect {
        our_fee_structure.calculate_fee(
          amount: 1000,
          source: source_from_us,
          platform_fee: 111,
          flat_fee: -1
        )
      }.to raise_error(ArgumentError)
    }

    it {
      expect {
        our_fee_structure.calculate_stripe_fee(
          amount: 1000,
          source: double("an object without #brand or #country")
        )
      }.to raise_error(ArgumentError)
    }
  end

  describe "#calculate_stripe_fee" do
    it {
      expect {
        our_fee_structure.calculate_stripe_fee(
          amount: -10,
          source: source_from_us
        )
      }.to raise_error(ArgumentError)
    }

    it {
      expect {
        our_fee_structure.calculate_stripe_fee(
          amount: 1000,
          source: nil
        )
      }.to raise_error(ArgumentError)
    }

    it {
      expect {
        our_fee_structure.calculate_stripe_fee(
          amount: 1000,
          source: double("an object without #brand or #country")
        )
      }.to raise_error(ArgumentError)
    }
  end
end

RSpec.describe FeeStructure, type: :model do
  include_context "Stripe::Source doubles"

  context "validation" do
    it { is_expected.to validate_presence_of(:stripe_fee) }
    it { is_expected.to validate_numericality_of(:stripe_fee).is_greater_than_or_equal_to(0).is_less_than(1) }
    it { is_expected.to validate_presence_of(:flat_fee) }
    it { is_expected.to validate_numericality_of(:flat_fee).is_greater_than_or_equal_to(0).only_integer }

    it { is_expected.to validate_presence_of(:fee_era) }

    it { is_expected.to delegate_method(:charge_international_fee?).to(:fee_era) }
    it { is_expected.to delegate_method(:international_surcharge_fee).to(:fee_era) }

    it { is_expected.to belong_to(:fee_era) }
  end

  describe "#calculate_fee" do
    context "using a fee structure with no local country" do
      subject(:our_fee_structure) { create(:no_international_fees_brandless_fee_structure) }
      it_behaves_like "a fee structure with calculation arg validation"

      context "and with a US card" do
        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.018", source: source_from_us)).to eq 430
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 100, platform_fee: "0.018", source: source_from_us)).to eq 34
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.038", source: source_from_us)).to eq 630
        }
      end

      context "and with a UK card" do
        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.018", source: source_from_uk)).to eq 430
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 100, platform_fee: "0.018", source: source_from_uk)).to eq 34
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.038", source: source_from_uk)).to eq 630
        }
      end
    end

    context "using a fee structure with a local country of US" do
      subject(:our_fee_structure) { create(:brandless_fee_structure) }
      it_behaves_like "a fee structure with calculation arg validation"
      context "and with a US card" do
        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.018", source: source_from_us)).to eq 430
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 100, platform_fee: "0.018", source: source_from_us)).to eq 34
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.038", source: source_from_us)).to eq 630
        }
      end

      context "and with a UK card" do
        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.018", source: source_from_uk)).to eq 530
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 100, platform_fee: "0.018", source: source_from_uk)).to eq 35
        }

        it {
          expect(our_fee_structure.calculate_fee(amount: 10000, platform_fee: "0.038", source: source_from_uk)).to eq 730
        }
      end
    end
  end

  describe "#calculate_stripe_fee" do
    context "using a fee structure with no local country" do
      subject(:our_fee_structure) { create(:no_international_fees_brandless_fee_structure) }
      it_behaves_like "a fee structure with calculation arg validation"

      context "and with a US card" do
        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 10000, source: source_from_us)).to eq 250
        }

        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 100, source: source_from_us)).to eq 33
        }
      end

      context "and with a UK card" do
        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 10000, source: source_from_uk)).to eq 250
        }

        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 100, source: source_from_uk)).to eq 33
        }
      end
    end

    context "using a fee structure with a local country of US" do
      subject(:our_fee_structure) { create(:brandless_fee_structure) }
      it_behaves_like "a fee structure with calculation arg validation"

      context "and with a US card" do
        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 10000, source: source_from_us)).to eq 250
        }

        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 100, source: source_from_us)).to eq 33
        }
      end

      context "and with a UK card" do
        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 10000, source: source_from_uk)).to eq 350
        }

        it {
          expect(our_fee_structure.calculate_stripe_fee(amount: 100, source: source_from_uk)).to eq 34
        }
      end
    end
  end
end
