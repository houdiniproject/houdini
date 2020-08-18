# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Charge, :type => :model do
  describe '.charge' do
    let(:charge){ force_create(:charge, stripe_charge_id: 'test_id')}
    let!(:stripe_dispute) { force_create(:stripe_dispute, stripe_charge_id: 'test_id')}
    it 'directs to a stripe_dispute with the correct Stripe charge id' do
      expect(charge.stripe_dispute).to eq stripe_dispute
    end
  end
end
