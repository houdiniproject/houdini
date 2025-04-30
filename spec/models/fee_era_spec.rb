require "rails_helper"
RSpec.describe FeeEra, type: :model do
  include_context "Stripe::Source doubles"

  around(:each) do |example|
    Timecop.freeze(2020, 5, 4) do
      example.run
    end
  end

  describe ".current" do
    context "when era exists" do
      let!(:fee_era) { create(:fee_era) }
      let!(:fee_era_with_no_start) { create(:fee_era_with_no_start) }
      let!(:fee_era_with_no_end) { create(:fee_era_with_no_end) }
      it "for current time" do
        expect(FeeEra.current).to eq fee_era
      end
    end

    context "when no era is found" do
      it {
        expect { FeeEra.current }.to raise_error(ActiveRecord::RecordNotFound)
      }
    end
  end

  describe ".find_by_time" do
    context "when era exists" do
      let!(:fee_era) { create(:fee_era) }
      let!(:fee_era_with_no_start) { create(:fee_era_with_no_start) }
      let!(:fee_era_with_no_end) { create(:fee_era_with_no_end) }
      it "for current time" do
        expect(FeeEra.find_by_time).to eq fee_era
      end

      it "for passed time during current era" do
        expect(FeeEra.find_by_time(Time.new(2020, 5, 3))).to eq fee_era
      end

      it "for passed time far in past" do
        expect(FeeEra.find_by_time(Time.new(2019, 5, 4))).to eq fee_era_with_no_start
      end

      it "for passed time at the beginning of last era" do
        expect(FeeEra.find_by_time(Time.new(2020, 5, 7))).to eq fee_era_with_no_end
      end

      it "for passed time far in future" do
        expect(FeeEra.find_by_time(Time.new(2100, 5, 4))).to eq fee_era_with_no_end
      end
    end
    context "when no era is found" do
      it {
        expect { FeeEra.find_by_time }.to raise_error(ActiveRecord::RecordNotFound)
      }
    end
  end

  describe "#in_era?" do
    let!(:fee_era) { create(:fee_era) }
    let!(:fee_era_with_no_start) { create(:fee_era_with_no_start) }
    let!(:fee_era_with_no_end) { create(:fee_era_with_no_end) }
    context "for current time" do
      it {
        expect(fee_era.in_era?).to eq true
      }

      it {
        expect(fee_era_with_no_start.in_era?).to eq false
      }

      it {
        expect(fee_era_with_no_end.in_era?).to eq false
      }
    end

    context "for passed time during current era" do
      let(:time) { Time.new(2020, 5, 3) }
      it {
        expect(fee_era.in_era?(time)).to eq true
      }

      it {
        expect(fee_era_with_no_start.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_end.in_era?(time)).to eq false
      }
    end

    context "for passed time far in past" do
      let(:time) { Time.new(2019, 5, 4) }
      it {
        expect(fee_era.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_start.in_era?(time)).to eq true
      }

      it {
        expect(fee_era_with_no_end.in_era?(time)).to eq false
      }
    end

    context "for passed time at the beginning of last era" do
      let(:time) { Time.new(2020, 5, 7) }
      it {
        expect(fee_era.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_start.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_end.in_era?(time)).to eq true
      }
    end

    context "for passed time far in future" do
      let(:time) { Time.new(2100, 5, 4) }
      it {
        expect(fee_era.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_start.in_era?(time)).to eq false
      }

      it {
        expect(fee_era_with_no_end.in_era?(time)).to eq true
      }
    end
  end

  context "validation" do
    it { is_expected.to validate_numericality_of(:international_surcharge_fee).is_greater_than_or_equal_to(0).is_less_than(1) }
    it { is_expected.to have_many(:fee_structures).validate(true) }
    it { is_expected.to have_one(:fee_coverage_detail_base).validate(true) }
    it { is_expected.to validate_presence_of(:fee_coverage_detail_base) }
  end

  describe ".find_fee_structure" do
    context "with structures for Visa, American Express and brandless" do
      subject(:fee_era) {
        create(:fee_era_with_structures)
      }
      context "for Visa" do
        subject { fee_era.find_fee_structure_by_source(visa_card) }
        it {
          is_expected.to have_attributes(brand: "Visa")
        }
      end

      context "for Amex" do
        subject { fee_era.find_fee_structure_by_source(amex_card) }
        it {
          is_expected.to have_attributes(brand: "American Express")
        }
      end

      context "and Discover" do
        subject { fee_era.find_fee_structure_by_source(discover_card) }
        it {
          is_expected.to have_attributes(brand: nil)
        }
      end

      context "and invalid source" do
        it {
          expect { fee_era.find_fee_structure_by_source(double("an invalid source")) }.to raise_error(ArgumentError)
        }
      end
    end
  end
end
