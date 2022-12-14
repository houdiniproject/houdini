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


  describe '#profile_todos' do
    let(:nonprofit) { create(:nonprofit)}
    let(:user) { create(:user_as_nonprofit_associate, nonprofit: nonprofit)  }
    context "not logged in" do
      it 'is unauthorized' do
        get "/nonprofits/#{nonprofit.id}/profile_todos"
        expect(response).to have_http_status 302
      end
    end
    
    context 'logged in' do
      before(:each) { sign_in user}
      it 'returns the proper json' do
        get "/nonprofits/#{nonprofit.id}/profile_todos"
        expect(JSON::parse(response.body)).to eq({
          "has_logo" => false,
          "has_background" => false,
          "has_summary" => false,
          "has_image" => false,
          "has_highlight" => false,
          "has_services" => false
        })
      end
    end
  end
end