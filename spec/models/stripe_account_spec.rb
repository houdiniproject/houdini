# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe StripeAccount, :type => :model do
  before(:each) do
    StripeMock.start
  end
  describe "account should be pending" do
    let(:json) do
      event =StripeMock.mock_webhook_event('account.updated.with-pending')
      event['data']['object']
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is pending' do
      expect(sa.verification_status).to eq :pending
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end


  describe "account goes from verified to unverified" do
    let(:json_verified) do
      event =StripeMock.mock_webhook_event('account.updated.with-verified')
      event['data']['object']
    end

    let(:json_unverified) do
      event =StripeMock.mock_webhook_event('account.updated.with-unverified-from-verified')
      event['data']['object']
    end

    let(:sa) do
      sa = StripeAccount.new
      sa.object = json_verified
      sa.save!
      sa.object = json_unverified
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
    let(:json) do
      event =StripeMock.mock_webhook_event('account.updated.with-unverified')
      event['data']['object']
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is unverified' do
      expect(sa.verification_status).to eq :unverified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be verified' do
    let(:json) do
      event =StripeMock.mock_webhook_event('account.updated.with-verified')
      event['data']['object']
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :verified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be temporarily verified' do
    let(:json) do
      event =StripeMock.mock_webhook_event('account.updated.with-temporarily_verified')
      event['data']['object']
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :temporarily_verified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to be_nil
    end
  end

  describe 'account should be unverified because of deadline' do
    let(:json) do
      event =StripeMock.mock_webhook_event('account.updated.with-temporarily_verified-with-deadline')
      event['data']['object']
    end

    let(:sa) do 
      sa = StripeAccount.new
      sa.object = json
      sa.save!
      sa
    end

    it 'is verified' do
      expect(sa.verification_status).to eq :unverified
    end

    it 'has nil deadline' do
      expect(sa.deadline).to eq Time.at(1580858639)
    end
  end
end
