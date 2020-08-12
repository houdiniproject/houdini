# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Dispute, :type => :model do
  describe '.charge' do
    let(:dispute){ force_create(:dispute)}
    let!(:stripe_dispute) { force_create(:stripe_dispute)}
    it 'directs to a stripe_dispute with the correct Stripe dispute id' do
      expect(dispute.stripe_dispute).to eq stripe_dispute
    end
  end
end
