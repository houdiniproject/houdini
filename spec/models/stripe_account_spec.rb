# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe StripeAccount, :type => :model do
  before(:each) do
    StripeMock.start
  end

  describe "account should be pending" do
    let(:sa) do 
      create(:stripe_account, :with_pending)
    end

    it 'is pending' do
      expect(sa.verification_status).to eq :pending
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe "account goes from verified to unverified" do
    let(:sa) do
      sa = create(:stripe_account, :with_verified)
      sa.object = attributes_for(:stripe_account, :with_unverified_from_verified)[:object].to_s
      sa.save!
      sa
    end

    it 'is unverified' do
      expect(sa.verification_status).to eq :unverified
    end

    it 'has deadline of 4 Feb 2020 20:37:19' do
      expect(sa.deadline).to eq Time.utc(2020, 2, 28, 22, 27, 35)
    end
  end

  describe 'account should be unverified' do
    let(:sa) do 
      create(:stripe_account, :with_unverified)
    end

    it 'is unverified' do
      expect(sa.verification_status).to eq :unverified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be verified' do

    subject(:sa) do 
      create(:stripe_account, :with_verified)
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :verified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be temporarily verified' do
    let(:sa) do 
      create(:stripe_account, :with_temporarily_verified)
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :temporarily_verified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be unverified because of deadline' do
    subject(:sa) do 
      create(:stripe_account, :with_temporarily_verified_with_deadline)
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :unverified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to eq Time.at(1580858639)
    end
  end
end
