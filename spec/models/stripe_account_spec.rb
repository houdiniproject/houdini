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
  end
end
