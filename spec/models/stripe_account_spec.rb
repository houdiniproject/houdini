# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe StripeAccount, type: :model do
  around(:each) do |example|
    StripeMockHelper.mock do
      example.run
    end
  end
  describe "account should be pending" do
    let(:sa) do
      create(:stripe_account, :with_pending)
    end

    it "is pending" do
      expect(sa.verification_status).to eq :pending
    end

    it "has nil deadline" do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account goes from verified to unverified" do
    let(:sa) do
      sa = create(:stripe_account, :with_verified)
      sa.object = attributes_for(:stripe_account, :with_unverified_from_verified)[:object]
      sa.save!
      sa
    end

    it "is unverified" do
      expect(sa.verification_status).to eq :unverified
    end

    it "has deadline of 4 Feb 2020 20:37:19" do
      expect(sa.deadline).to eq Time.utc(2020, 2, 28, 22, 27, 35)
    end
  end

  describe "account should be unverified" do
    let(:sa) do
      create(:stripe_account, :with_unverified)
    end

    it "is unverified" do
      expect(sa.verification_status).to eq :unverified
    end

    it "has nil deadline" do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account should be verified" do
    subject(:sa) do
      create(:stripe_account, :with_verified)
    end

    it "is verified" do
      expect(sa.verification_status).to eq :verified
    end

    it "has nil deadline" do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account should be temporarily verified" do
    let(:sa) do
      create(:stripe_account, :with_temporarily_verified)
    end

    it "is verified" do
      expect(sa.verification_status).to eq :temporarily_verified
    end

    it "has nil deadline" do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account should be unverified because of there is a future_requirements deadline" do
    subject(:sa) do
      create(:stripe_account, :with_verified_and_bank_provided_but_future_requirements)
    end

    it "is unverified" do
      expect(sa.verification_status).to eq :unverified
    end

    it "has Time.at(1581712639) deadline" do
      expect(sa.deadline).to eq Time.at(1581712639)
    end
  end

  describe "account should be unverified because of there is a future_requirements deadline" do
    subject(:sa) do
      create(:stripe_account, :with_verified_and_bank_provided_but_future_requirements_pending)
    end

    it "is pending" do
      expect(sa.verification_status).to eq :pending
    end

    it "has Time.at(1581712639) deadline" do
      expect(sa.deadline).to eq Time.at(1581712639)
    end
  end

  describe "account should be verified because of there is a future_requirements deadline but not values still due" do
    subject(:sa) do
      create(:stripe_account, :with_verified_and_bank_provided_with_active_but_empty_future_requirements)
    end

    it "is verified" do
      expect(sa.verification_status).to eq :verified
    end

    it "has nil deadline" do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account should be unverified because of deadline" do
    subject(:sa) do
      create(:stripe_account, :with_temporarily_verified_with_deadline)
    end

    it "is verified" do
      expect(sa.verification_status).to eq :unverified
    end

    it "has nil deadline" do
      expect(sa.deadline).to eq Time.at(1580858639)
    end
  end

  describe ".without_future_requirements" do
    let!(:sa) do
      create(:stripe_account, :without_future_requirements)
    end

    it { expect(StripeAccount.without_future_requirements.count).to eq 1 }
    it { expect(StripeAccount.with_future_requirements.count).to eq 0 }
  end

  describe ".with_future_requirements" do
    let!(:sa) do
      create(:stripe_account, :with_pending)
    end

    it { expect(StripeAccount.without_future_requirements.count).to eq 0 }
    it { expect(StripeAccount.with_future_requirements.count).to eq 1 }
  end

  # describe '#future_requirements' do
  #   subject(:future_requirements) {
  #     create(:stripe_account, :with_pending).future_requirements
  #   }

  #   it do
  #     expect(future_requirements.current_deadline).to eq Time.at(1580935094)
  #   end

  #   it do
  #     expect(future_requirements.currently_due.count).to eq 8
  #   end

  #   it do
  #     expect(future_requirements.eventually_due.count).to eq 9
  #   end

  #   it do
  #     expect(future_requirements.past_due.count).to eq 6
  #   end
  # end
end
