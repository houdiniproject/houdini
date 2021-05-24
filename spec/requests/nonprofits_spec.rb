# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'support/contexts/shared_donation_charge_context'
describe NonprofitsController, type: :request do
  include_context :shared_donation_charge_context
  let(:our_np) do
    billing_subscription
    nonprofit
  end

  describe '#donate' do
    it 'allows being put into a frame by not setting X-Frame-Options header' do
      get "/nonprofits/#{our_np.id}/donate"
      expect(response.status).to eq 200
      expect(response.headers).to_not include 'X-Frame-Options'
    end
  end

  describe '#btn' do
    it 'allows being put into a frame by not setting X-Frame-Options header' do
      get "/nonprofits/#{our_np.id}/btn"
      expect(response.status).to eq 200
      expect(response.headers).to_not include 'X-Frame-Options'
    end
  end
end