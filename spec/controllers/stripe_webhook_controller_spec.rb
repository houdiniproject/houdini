require 'rails_helper'

RSpec.describe StripeWebhookController, :type => :controller do

  describe "POST #receive" do
    # describe 'authorization' do
    #   include_context :shared_user_context
    #   describe 'accept all' do
    #     describe 'receive' do
    #         include_context :open_to_all, :post, :receive
    #     end
    #   end
    # end

    describe 'verification of input' do
      it 'returns on bad json' do
        expect(JSON).to receive(:parse).and_raise(JSON::ParserError)
        post :receive
        expect(response.body).to eq ({error: "Invalid payload"}.to_json)
        expect(response.status).to eq 400
      end

      it 'returns on bad signature' do
        raw_post :receive, {}, {}.to_json
        expect(response.body).to eq ({error: 'Invalid signature'}.to_json)
        expect(response.status).to eq 400
      end

      it 'returns on other error' do
        expect(JSON).to receive(:parse).and_raise(ArgumentError)
        request.headers['HTTP_STRIPE_SIGNATURE']= ""
        raw_post :receive, {}, {}.to_json
        expect(response.body).to eq ({error: "Unspecified error"}.to_json)
        expect(response.status).to eq 400
      end
    end

    it 'succeeds' do
      event = Object.new
      expect(Stripe::Webhook).to receive(:construct_event).and_return(event)
      expect(StripeEvent).to receive(:handle).with(event)
      raw_post :receive, {}, {}.to_json
      expect(response.body).to eq ({}.to_json)
      expect(response.status).to eq 200
    end
  end
end
