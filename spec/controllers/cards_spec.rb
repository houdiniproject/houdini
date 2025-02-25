# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'controllers/support/shared_user_context'

describe CardsController, :type => :controller do
  describe 'authorization' do
    include_context :shared_user_context
    describe 'accept all' do
      describe 'create' do
          include_context :open_to_all, :post, :create, nonprofit_id: :__our_np
      end
    end
  end

  it {is_expected.to rescue_from(::Recaptcha::RecaptchaError).with(:handle_recaptcha_failure)}

  it {is_expected.to use_before_action(:verify_via_recaptcha!)}
  
  describe '#create' do
    context 'recaptcha' do
      it 'handles verification failure' do 
        expect(controller).to receive(:verify_recaptcha).and_return(false)
        expect {
          post :create, params: {:recaptcha_response_field => "response", 'g-recaptcha-response-data' => 'string', type: :json}
        }.to change { RecaptchaRejection.count}.by(1)
      
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include "5X4J"
      end
    end
  end
end