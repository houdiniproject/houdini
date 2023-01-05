# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe BillingSubscription, type: :model do

  describe 'Caching' do
    describe '.clear_cache' do
      it 'clears the cache when an id is passed' do
        expect(Rails.cache).to receive(:delete).with("billing_subscription_nonprofit_id_1")
        described_class.clear_cache(1)
      end

      it 'clears the cache when an nonprofit is passed' do
        np = create(:nonprofit)
        expect(Rails.cache).to receive(:delete).with("billing_subscription_nonprofit_id_#{np.id}")
        described_class.clear_cache(np)
      end
    end

    describe '.create_cache_key' do
      it 'clears the proper key when id is an integer' do
        expect(described_class.create_cache_key(1)).to eq "billing_subscription_nonprofit_id_1"
      end

      it 'clears the proper key when id is a nonprofit' do
        np = create(:nonprofit)
        expect(described_class.create_cache_key(np)).to eq "billing_subscription_nonprofit_id_#{np.id}"
      end
    end
  end
end
