# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe Dispute, :type => :model do
  describe '.charge' do
    include_context :disputes_context
    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
        supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))}
    let!(:obj) { force_create(:stripe_dispute, stripe_charge_id: charge.stripe_charge_id)}
    it 'directs to a stripe_dispute with the correct Stripe dispute id' do
      expect(dispute.stripe_dispute).to eq obj
    end
  end
end
